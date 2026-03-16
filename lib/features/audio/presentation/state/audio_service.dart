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

  final Set<String> _downloadingTasks = {};

  Future<void> init(WidgetRef ref) async {

    await configureAudioSession();

    _audioPlayer.currentIndexStream.listen((index) {
      if (index == null) return;
      final current = ref.read(currentPlayingAyahProvider);
      int ayahNumber = index + 1;

      if (current != null) {
        ref.read(currentPlayingAyahProvider.notifier).state = AyahIdentifier(
          surah: current.surah,
          ayah: ayahNumber,
          page: current.page,
        );
      }
    });

    _audioPlayer.processingStateStream.listen((state) async {
      if (state == ProcessingState.completed) {
        final repeatMode = ref.read(repeatModeProvider);
        final currentReciter = ref.read(selectedReciterProvider);
        final currentIndex = ref.read(selectedSurahIndexProvider)!;
        final surahsAsync = ref.read(surahListProvider);

        if (surahsAsync is AsyncData<List<Surah>>) {
          final surahs = surahsAsync.value;

          if (repeatMode == RepeatStates.repeatAll) {
            final nextIndex = (currentIndex + 1) % surahs.length;
            ref.read(selectedSurahIndexProvider.notifier).state = nextIndex;

            final nextSurah = surahs[nextIndex];
            await playSurah(
              reciter: currentReciter!,
              surah: nextSurah,
              allSurahs: surahs,
            );
          } else if (repeatMode == RepeatStates.repeatOne) {
            final surah = surahs[currentIndex];
            await playSurah(
              reciter: currentReciter!,
              surah: surah,
              allSurahs: surahs,
            );
          } else {
            await _audioPlayer.pause();
            await _audioPlayer.seek(Duration.zero, index: 0);
          }
        }
      }
    });
  }

  bool _hasLoadedSurah = false;

  bool get hasLoadedSurah => _hasLoadedSurah;

  AudioPlayer get player => _audioPlayer;



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
    required String reciterFolder,
    required String dirPath,
  }) async {
    final surahStr = surah.number.toString().padLeft(3, '0');
    final ayahStr = ayah.toString().padLeft(3, '0');

    final url = "https://everyayah.com/data/$reciterFolder/$surahStr$ayahStr.mp3";
    final fileName = "$surahStr$ayahStr.mp3";
    final localPath = "$dirPath/$reciterFolder/$fileName";

    if (await File(localPath).exists()) {
    return AudioSource.file(
      localPath,
      tag: MediaItem(
        id: "${surah.number}:$ayah",
        album: "Quran",
        title: "Surah ${surah.nameEnglish} - Ayah $ayah",
        artist: reciterFolder,
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
        artist: reciterFolder,
      ),
    );
    }

  }

  Future<void> playVerse({
    required String reciterFolder,
    required Surah surah,
    required int ayah,
  }) async {

    final session = await AudioSession.instance;
    await session.setActive(true);

    await _audioPlayer.stop();
    await _ayahPlayer.stop();

    final directory = await getApplicationDocumentsDirectory();

    final audioSource = await buildUrl(
      surah: surah,
      ayah: ayah,
      reciterFolder: reciterFolder,
      dirPath: directory.path,
    );

    await _ayahPlayer.setAudioSource(audioSource);

    await _ayahPlayer.play();
  }


  Future<void> playSurah({
    required Reciter reciter,
    required Surah surah,
    required List<Surah> allSurahs,
  }) async {

    await _ayahPlayer.stop();
    await _audioPlayer.pause();
    final directory = await getApplicationDocumentsDirectory();

    final currentIndex = surah.number - 1;

    List<Surah> playlistSurahs = [];

    if (currentIndex > 0) {
      playlistSurahs.add(allSurahs[currentIndex - 1]);
    }

    playlistSurahs.add(allSurahs[currentIndex]);

    if (currentIndex < allSurahs.length - 1) {
      playlistSurahs.add(allSurahs[currentIndex + 1]);
    }

    List<AudioSource> sources = [];

    for (var s in playlistSurahs) {
      final source = await _buildSingleAudioSource(s, reciter, directory.path);
      sources.add(source);
    }

    await _audioPlayer.setAudioSources(
      sources,
      initialIndex: playlistSurahs.indexWhere((s) => s.number == surah.number),
    );

    _hasLoadedSurah = true;

    final surahStr = surah.number.toString().padLeft(3, '0');
    final fileName = "$surahStr.mp3";
    final localPath = "$directory.path/${reciter.audioFolder}/$fileName";
    final url = "${reciter.serverUrl}/$fileName";

    _startBackgroundDownload(url, localPath);

    await _audioPlayer.play();
  }

// Helper to create a single source (Check Cache -> Fallback to URL)
  Future<AudioSource> _buildSingleAudioSource(Surah surah, Reciter reciter, String dirPath) async {
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
    // If this specific path is already being downloaded, exit immediately
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

      print("Download started: $url");

      await dio.download(
        url,
        tempPath,
        deleteOnError: true,
      );

      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.rename(savePath);
        print("Download finished: $savePath");
      }

    } catch (e) {
      print("Download failed: $e");
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
    await _audioPlayer.seek(Duration.zero, index: 0);
    await _audioPlayer.stop();
    _hasLoadedSurah = false;
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  Future<void> configureAudioSession() async {
    final session =  await AudioSession.instance;

    await session.configure(
      const AudioSessionConfiguration.speech(),
    );
  }

}
