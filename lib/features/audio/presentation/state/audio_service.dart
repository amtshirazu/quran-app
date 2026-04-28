import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_app/features/audio/presentation/state/repeat_states.dart';
import 'package:audio_session/audio_session.dart';
import '../../../quran/domain/models/surah.dart';
import '../../../quran/presentation/state/quran_providers.dart';
import '../../domain/models/Reciters.dart';
import 'audio_providers.dart';

class QuranAudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _ayahPlayer = AudioPlayer();

  bool _isUserSelecting = false;

  void setUserSelecting(bool value) {
    _isUserSelecting = value;
  }

  final Set<String> _downloadingTasks = {};

  Future<void> init(WidgetRef ref) async {
    await configureAudioSession();

    _ayahPlayer.currentIndexStream.listen((index) {
      if (index == null) return;
      final current = ref.read(currentPlayingAyahProvider);

      final sequence = _ayahPlayer.sequence;
      if (index >= sequence.length) return;

      final source = sequence[index];
      final mediaItem = source.tag as MediaItem?;

      if (mediaItem != null) {
        final parts = mediaItem.id.split(':');
        int surahNum = int.parse(parts[0]);
        int ayahNum = int.parse(parts[1]);

        ref.read(currentPlayingAyahProvider.notifier).state = AyahIdentifier(
          surah: surahNum,
          ayah: ayahNum,
          page: current!.page,
        );
      }
    });

    _audioPlayer.currentIndexStream.listen((index) {
      if (_isUserSelecting) return;

      if (index == null) return;

      final sequence = _audioPlayer.sequence;
      if (sequence == null || index >= sequence.length) return;

      final source = sequence[index];
      final mediaItem = source.tag as MediaItem?;

      if (mediaItem != null) {
        int surahNumber = int.parse(mediaItem.id);
        int actualListIndex = surahNumber - 1;

        final currentSelected = ref.read(selectedSurahIndexProvider);

        if (currentSelected != actualListIndex) {
          ref.read(selectedSurahIndexProvider.notifier).state = actualListIndex;
        }
      }
    });

    _ayahPlayer.positionStream.listen((position) async {
      final repeatMode = ref.read(repeatModeProvider);
      final duration = _ayahPlayer.duration;

      if ((repeatMode == RepeatStates.off ||
              repeatMode == RepeatStates.repeatOne ||
              repeatMode == RepeatStates.repeatAll) &&
          duration != null) {
        final finishLine = duration - const Duration(milliseconds: 200);

        if (position >= finishLine) {
          await _ayahPlayer.pause();

          await _ayahPlayer.seek(Duration.zero);
        }
      }
    });

    _audioPlayer.positionStream.listen((position) async {
      final repeatMode = ref.read(repeatModeProvider);
      final duration = _audioPlayer.duration;

      if (repeatMode == RepeatStates.off && duration != null) {
        final finishLine = duration - const Duration(milliseconds: 200);

        if (position >= finishLine) {
          await _audioPlayer.pause();

          await _audioPlayer.seek(Duration.zero);
        }
      }
    });
  }

  bool _hasLoadedSurah = false;

  bool get hasLoadedSurah => _hasLoadedSurah;

  AudioPlayer get player => _audioPlayer;

  Future<void> updateRepeatMode(RepeatStates mode) async {
    final loopMode = switch (mode) {
      RepeatStates.repeatAll => LoopMode.all,
      RepeatStates.repeatOne => LoopMode.one,
      RepeatStates.off => LoopMode.off,
    };

    await _audioPlayer.setLoopMode(loopMode);
    await _ayahPlayer.setLoopMode(loopMode);
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    await _audioPlayer.seek(Duration.zero, index: 0);
  }

  void dispose() {
    _audioPlayer.dispose();
  }

  Future<AudioSource> buildUrl({
    required Surah surah,
    required int ayah,
    required Reciter reciter,
    required String dirPath,
  }) async {
    final surahStr = surah.number.toString().padLeft(3, '0');
    final ayahStr = ayah.toString().padLeft(3, '0');

    final url =
        "https://everyayah.com/data/${reciter.audioFolder}/$surahStr$ayahStr.mp3";
    final fileName = "$surahStr$ayahStr.mp3";
    final localPath = "$dirPath/${reciter.audioFolder}/$fileName";

    if (await File(localPath).exists()) {
      return AudioSource.file(
        localPath,
        tag: MediaItem(
          id: "${surah.number}:$ayah",
          album: "Quran",
          title: "Surah ${surah.nameEnglish} - Ayah $ayah",
          artist: reciter.name,
        ),
      );
    } else {
      _startBackgroundDownload(url, localPath);
      return AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: "${surah.number}:$ayah",
          album: "Quran",
          title: "Surah ${surah.nameEnglish} - Ayah $ayah",
          artist: reciter.name,
        ),
      );
    }
  }

  Future<void> playVerse({
    required Reciter reciter,
    required Surah surah,
    required int ayah,
  }) async {
    final session = await AudioSession.instance;
    await session.setActive(true);
    _audioPlayer.stop();
    _ayahPlayer.stop();

    final directory = await getApplicationDocumentsDirectory();
    final currentAyahIndex = ayah - 1;

    List<Future<AudioSource>> windowFutures = [];

    if (currentAyahIndex > 0) {
      windowFutures.add(
        buildUrl(
          surah: surah,
          ayah: ayah - 1,
          reciter: reciter,
          dirPath: directory.path,
        ),
      );
    }

    windowFutures.add(
      buildUrl(
        surah: surah,
        ayah: ayah,
        reciter: reciter,
        dirPath: directory.path,
      ),
    );

    if (currentAyahIndex < surah.totalAyahs - 1) {
      windowFutures.add(
        buildUrl(
          surah: surah,
          ayah: ayah + 1,
          reciter: reciter,
          dirPath: directory.path,
        ),
      );
    }

    final windowSources = await Future.wait(windowFutures);

    await _ayahPlayer.setAudioSources(
      windowSources,
      initialIndex: currentAyahIndex > 0 ? 1 : 0,
    );

    _ayahPlayer.play();

    _fillRestOfAyahPlaylist(
      windowSources,
      surah,
      currentAyahIndex,
      reciter,
      directory.path,
    );
  }

  void _fillRestOfAyahPlaylist(
    List<AudioSource> playlist,
    Surah surah,
    int currentIdx,
    Reciter reciter,
    String path,
  ) async {
    for (int i = 1; i <= surah.totalAyahs; i++) {
      int indexInList = i - 1;

      if (indexInList == currentIdx ||
          indexInList == currentIdx - 1 ||
          indexInList == currentIdx + 1) {
        continue;
      }

      final source = await buildUrl(
        surah: surah,
        ayah: i,
        reciter: reciter,
        dirPath: path,
      );

      if (indexInList < currentIdx - 1) {
        playlist.insert(indexInList, source);
      } else {
        playlist.add(source);
      }
    }
  }

  Future<void> playSurah({
    required Reciter reciter,
    required Surah surah,
    required List<Surah> allSurahs,
  }) async {
    final session = await AudioSession.instance;
    await session.setActive(true);

    await _ayahPlayer.stop();
    await _audioPlayer.stop();

    final directory = await getApplicationDocumentsDirectory();
    final currentIndex = allSurahs.indexWhere((s) => s.number == surah.number);

    final prevIdx = currentIndex > 0 ? currentIndex - 1 : null;
    final nextIdx = currentIndex < allSurahs.length - 1
        ? currentIndex + 1
        : null;

    List<Future<AudioSource>> windowFutures = [];

    if (prevIdx != null) {
      windowFutures.add(
        _buildSingleAudioSource(allSurahs[prevIdx], reciter, directory.path),
      );
    }

    windowFutures.add(
      _buildSingleAudioSource(allSurahs[currentIndex], reciter, directory.path),
    );

    if (nextIdx != null) {
      windowFutures.add(
        _buildSingleAudioSource(allSurahs[nextIdx], reciter, directory.path),
      );
    }

    final windowSources = await Future.wait(windowFutures);

    await _audioPlayer.setAudioSources(
      windowSources,
      initialIndex: prevIdx != null ? 1 : 0,
    );

    _hasLoadedSurah = true;
    _audioPlayer.play();

    final surahStr = surah.number.toString().padLeft(3, '0');
    final fileName = "$surahStr.mp3";
    final localPath = "$directory.path/${reciter.audioFolder}/$fileName";
    final url = "${reciter.serverUrl}/$fileName";

    _startBackgroundDownload(url, localPath);

    _fillRestOfSurahPlaylist(
      windowSources,
      allSurahs,
      currentIndex,
      reciter,
      directory.path,
    );
  }

  void _fillRestOfSurahPlaylist(
    List<AudioSource> playlist,
    List<Surah> all,
    int currentIdx,
    Reciter reciter,
    String path,
  ) async {
    for (int i = 0; i < all.length; i++) {
      if (i == currentIdx || i == currentIdx - 1 || i == currentIdx + 1)
        continue;

      final source = await _buildSingleAudioSource(all[i], reciter, path);

      if (i < currentIdx - 1) {
        playlist.insert(i, source);
      } else {
        playlist.add(source);
      }
    }
  }

  Future<AudioSource> _buildSingleAudioSource(
    Surah surah,
    Reciter reciter,
    String dirPath,
  ) async {
    final surahStr = surah.number.toString().padLeft(3, '0');
    final fileName = "$surahStr.mp3";
    final localPath = "$dirPath/${reciter.audioFolder}/$fileName";
    final url = "${reciter.serverUrl}/$fileName";

    if (await File(localPath).exists()) {
      return AudioSource.file(
        localPath,
        tag: MediaItem(
          id: '${surah.number}',
          album: surah.translation,
          title: 'Surah ${surah.nameEnglish}',
          artist: reciter.name,
        ),
      );
    } else {
      return AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: '${surah.number}',
          album: surah.translation,
          title: 'Surah ${surah.nameEnglish}',
          artist: reciter.name,
        ),
      );
    }
  }

  Future<void> _startBackgroundDownload(String url, String savePath) async {
    if (_downloadingTasks.contains(savePath)) {
      return;
    }

    try {
      final file = File(savePath);

      if (await file.exists()) return;

      _downloadingTasks.add(savePath);

      await file.parent.create(recursive: true);
      final tempPath = "$savePath.temp";

      final dio = Dio();

      await dio.download(url, tempPath, deleteOnError: true);

      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.rename(savePath);
      }
    } catch (e) {
      final tempFile = File("$savePath.temp");
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } finally {
      _downloadingTasks.remove(savePath);
    }
  }

  Future<void> seekToStart() async {
    await _audioPlayer.seek(Duration.zero, index: 0);
  }

  Future<void> reset() async {
    await _audioPlayer.stop();
    await _audioPlayer.clearAudioSources();
    _hasLoadedSurah = false;
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  Future<void> configureAudioSession() async {
    final session = await AudioSession.instance;

    await session.configure(const AudioSessionConfiguration.music());
  }
}
