import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_app/features/audio/presentation/state/repeat_states.dart';

import '../../../quran/domain/models/surah.dart';
import '../../../quran/presentation/state/quran_providers.dart';
import 'audio_providers.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _hasBasmallah = false;

  void init(WidgetRef ref) {
    _audioPlayer.currentIndexStream.listen((index) {
      if (index == null) return;
      final current = ref.read(currentPlayingAyahProvider);
      int ayahNumber = index + 1;

      if (_hasBasmallah) {
        ayahNumber = index;
        if (ayahNumber == 0) return;
      }

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
              reciterFolder: currentReciter!.audioFolder,
              surah: nextSurah.number,
              totalAyahs: nextSurah.totalAyahs,
            );
          } else if (repeatMode == RepeatStates.repeatOne) {
            final surah = surahs[currentIndex];
            await playSurah(
              reciterFolder: currentReciter!.audioFolder,
              surah: surah.number,
              totalAyahs: surah.totalAyahs,
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

  Future<void> playVerse({
    required String reciterFolder,
    required int surah,
    required int ayah,
  }) async {
    final url = buildUrl(
      surah: surah,
      ayah: ayah,
      reciterFolder: reciterFolder,
    );
    await playUrl(url);
  }

  Future<void> playUrl(String url) async {
    await _audioPlayer.setUrl(url);
    await _audioPlayer.play();
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

  String buildUrl({
    required int surah,
    required int ayah,
    required String reciterFolder,
  }) {
    final surahStr = surah.toString().padLeft(3, '0');
    final ayahStr = ayah.toString().padLeft(3, '0');

    return "https://everyayah.com/data/$reciterFolder/$surahStr$ayahStr.mp3";
  }

  int? _currentActiveSurah;

  Future<void> playSurah({
    required String reciterFolder,
    required int surah,
    required int totalAyahs,
  }) async {

    _currentActiveSurah = surah;
    await _audioPlayer.pause();
    final directory = await getApplicationDocumentsDirectory();
    final surahStr = surah.toString().padLeft(3, '0');

    // Build only the first 2 Ayahs to start
    List<AudioSource> initialSources = [];
    for (int i = 1; i <= (totalAyahs < 2 ? totalAyahs : 2); i++) {
      initialSources.add(await _buildSingleAudioSource(i, surahStr, reciterFolder, directory.path));
    }

    await _audioPlayer.setAudioSources(
      initialSources,
      initialIndex: 0,
      initialPosition: Duration.zero,
    );

    _hasLoadedSurah = true;
    _audioPlayer.play();

    // 3. Background: Load and APPEND the rest
    _appendRemainingAyahs(
      currentSessionSurah: surah,
      startFrom: 3,
      totalAyahs: totalAyahs,
      surahStr: surahStr,
      reciterFolder: reciterFolder,
      directoryPath: directory.path,
    );
  }

// Helper to create a single source (Check Cache -> Fallback to URL)
  Future<AudioSource> _buildSingleAudioSource(int i, String surahStr, String reciterFolder, String dirPath) async {
    final fileName = "$surahStr${i.toString().padLeft(3, '0')}.mp3";
    final localPath = "$dirPath/$reciterFolder/$fileName";
    final url = "https://everyayah.com/data/$reciterFolder/$fileName";

    if (await File(localPath).exists()) {
      return AudioSource.file(localPath);
    } else {
      _startBackgroundDownload(url, localPath);
      return AudioSource.uri(Uri.parse(url));
    }
  }

// Background Task: Appends the rest of the Surah while Ayah 1 is playing
  Future<void> _appendRemainingAyahs({
    required int currentSessionSurah,
    required int startFrom,
    required int totalAyahs,
    required String surahStr,
    required String reciterFolder,
    required String directoryPath,
  }) async {
    for (int i = startFrom; i <= totalAyahs; i++) {

      if (_currentActiveSurah != currentSessionSurah) {
        debugPrint("Stopping old background loop for Surah $currentSessionSurah");
        return; // Kill this loop immediately!
      }

      final source = await _buildSingleAudioSource(i, surahStr, reciterFolder, directoryPath);

      await _audioPlayer.addAudioSource(source);
    }
  }

  // Background downloading helper
  Future<void> _startBackgroundDownload(String url, String savePath) async {
    try {
      final file = File(savePath);
      if (await file.exists()) return;

      await file.parent.create(recursive: true);
      final tempPath = "$savePath.temp"; // Temporary name

      final dio = Dio();
      await dio.download(url, tempPath);

      // Rename temp file to actual file name once finished
      await File(tempPath).rename(savePath);
    } catch (e) {
      print("Caching failed for $url: $e");
    }
  }

  Future<void> seekToStart() async {
    await _audioPlayer.seek(Duration.zero, index: 0);
  }

  Future<void> reset() async {
    _currentActiveSurah = null;
    await _audioPlayer.seek(Duration.zero, index: 0);
    await _audioPlayer.stop();
    await _audioPlayer.setAudioSources([]); // Clears the list
    _hasLoadedSurah = false;
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }
}
