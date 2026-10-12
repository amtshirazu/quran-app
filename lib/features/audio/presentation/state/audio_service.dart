import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran/quran.dart' as quran;

import 'package:quran_app/core/database/database_helper.dart';
import 'package:quran_app/features/audio/presentation/state/repeat_states.dart';

import '../../../quran/domain/models/surah.dart';
import '../../../quran/presentation/state/quran_providers.dart';
import '../../domain/models/Reciters.dart';
import 'audio_providers.dart';

class QuranAudioService {
  // ===========================================================================
  // AUDIO PLAYERS
  // ===========================================================================

  /// Main player: holds the entire 114-Surah ConcatenatingAudioSource playlist.
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Separate player for individual Ayah playback (single Ayah).
  final AudioPlayer _ayahPlayer = AudioPlayer();

  // ===========================================================================
  // STATE & SUBSCRIPTIONS
  // ===========================================================================

  final Set<String> _downloadingTasks = {};

  StreamSubscription<int?>? _currentIndexSubscription;
  StreamSubscription<Duration>? _positionSubscription;

  Ref? _ref;
  bool _initialized = false;
  bool _hasLoadedSurah = false;
  bool _isHandlingTrackBoundary = false;

  /// Prevents transient engine index resets (e.g. index 0 on load) from
  /// overriding user selection and flickering the UI.
  bool _isChangingTrack = false;

  /// Tracks previous position to catch natural end-of-track loop wraps accurately.
  Duration _lastReportedPosition = Duration.zero;

  /// Current repeat mode.
  RepeatStates _repeatMode = RepeatStates.repeatAll;

  /// The full Surah list and reciter currently loaded in the playlist.
  List<Surah> _allSurahs = const [];
  Reciter? _reciter;

  bool get hasLoadedSurah => _hasLoadedSurah;
  bool get isPlaying => _audioPlayer.playing;
  AudioPlayer get player => _audioPlayer;
  AudioPlayer get ayahPlayer => _ayahPlayer;

  // ===========================================================================
  // INITIALIZE SERVICE
  // ===========================================================================

  Future<void> init(Ref ref) async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    _ref = ref;

    _repeatMode = ref.read(repeatModeProvider);

    await configureAudioSession();
    await _applyLoopMode();

    // 1. Keep UI synced when playback advances naturally, but ignore during manual load/seeks
    _currentIndexSubscription = _audioPlayer.currentIndexStream.listen((index) {
      if (_isChangingTrack) {
        return;
      }

      if (index != null && index >= 0 && index < _allSurahs.length) {
        _ref?.read(selectedSurahIndexProvider.notifier).state = index;
      }
    });

    // 2. Full-fidelity End-of-Surah Handler for Repeat OFF
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (_repeatMode != RepeatStates.off || _isHandlingTrackBoundary) {
        _lastReportedPosition = position;
        return;
      }

      final duration = _audioPlayer.duration;

      if (duration != null && duration > const Duration(seconds: 1)) {
        final reachedAbsoluteEnd = position >= duration;
        final nearEnd = _lastReportedPosition >= duration - const Duration(milliseconds: 1500);
        final loopedBackToZero = position < const Duration(milliseconds: 200) && nearEnd;

        if (reachedAbsoluteEnd || loopedBackToZero) {
          unawaited(_handleRepeatOffTrackEnded());
        }
      }

      _lastReportedPosition = position;
    });
  }

  // ===========================================================================
  // REPEAT OFF HANDLER
  // ===========================================================================

  Future<void> _handleRepeatOffTrackEnded() async {
    if (_isHandlingTrackBoundary) return;
    _isHandlingTrackBoundary = true;

    try {
      await _audioPlayer.pause();
      await _audioPlayer.seek(Duration.zero);
      _lastReportedPosition = Duration.zero;
    } catch (e) {
      debugPrint('Error pausing at track boundary: $e');
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      _isHandlingTrackBoundary = false;
    }
  }

  // ===========================================================================
  // REPEAT MODE CONFIGURATION
  // ===========================================================================

  Future<void> updateRepeatMode(RepeatStates repeatMode) async {
    _repeatMode = repeatMode;
    await _applyLoopMode();
  }

  Future<void> _applyLoopMode() async {
    switch (_repeatMode) {
      case RepeatStates.repeatOne:
      case RepeatStates.off:
        await _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case RepeatStates.repeatAll:
        await _audioPlayer.setLoopMode(LoopMode.all);
        break;
    }
  }

  // ===========================================================================
  // PLAY SURAH
  // ===========================================================================

  Future<void> playSurah({
    required Reciter reciter,
    required Surah surah,
    required List<Surah> allSurahs,
  }) async {
    final session = await AudioSession.instance;
    await session.setActive(true);

    if (_ayahPlayer.playing) {
      await _ayahPlayer.stop();
    }

    final targetIndex = allSurahs.indexWhere(
          (s) => s.number == surah.number,
    );

    if (targetIndex == -1) {
      throw ArgumentError(
        'Surah ${surah.number} was not found in allSurahs.',
      );
    }

    // Set lock to prevent currentIndexStream race conditions from updating UI
    _isChangingTrack = true;
    _ref?.read(selectedSurahIndexProvider.notifier).state = targetIndex;

    _allSurahs = allSurahs;

    final isNewReciter = _reciter?.id != reciter.id;
    final isPlaylistEmpty = _audioPlayer.sequence.isEmpty;
    _reciter = reciter;

    await _applyLoopMode();

    final directory = await getApplicationDocumentsDirectory();

    try {
      if (isNewReciter || isPlaylistEmpty) {
        final sources = await Future.wait(
          allSurahs.map(
                (s) => _buildSingleAudioSource(s, reciter, directory.path),
          ),
        );

        final playlist = ConcatenatingAudioSource(
          useLazyPreparation: true,
          children: sources,
        );

        await _audioPlayer.setAudioSource(
          playlist,
          initialIndex: targetIndex,
          initialPosition: Duration.zero,
        );
      } else {
        if (_audioPlayer.currentIndex != targetIndex) {
          await _audioPlayer.seek(Duration.zero, index: targetIndex);
        } else {
          await _audioPlayer.seek(Duration.zero);
        }
      }

      _lastReportedPosition = Duration.zero;
      _hasLoadedSurah = true;

      unawaited(_audioPlayer.play());
    } finally {
      // Allow the player engine to stabilize before releasing lock
      Future.delayed(const Duration(milliseconds: 300), () {
        _isChangingTrack = false;
      });
    }

    // Background download check for current Surah
    final surahStr = surah.number.toString().padLeft(3, '0');
    final fileName = '$surahStr.mp3';
    final localPath = '${directory.path}/${reciter.audioFolder}/$fileName';

    final streamingSetting = await DatabaseHelper.instance.getSetting(
      'streaming_mode',
    );
    final isStreamingOnly = streamingSetting == 'true';

    if (!isStreamingOnly && !(await File(localPath).exists())) {
      final cleanBaseUrl = reciter.serverUrl.endsWith('/')
          ? reciter.serverUrl.substring(0, reciter.serverUrl.length - 1)
          : reciter.serverUrl;
      final url = '$cleanBaseUrl/$fileName';
      unawaited(_startBackgroundDownload(url, localPath));
    }
  }

  // ===========================================================================
  // PLAY / PAUSE / STOP / SEEK
  // ===========================================================================

  Future<void> play() async {
    unawaited(_audioPlayer.play());
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    if (_audioPlayer.sequence.isNotEmpty) {
      await _audioPlayer.seek(Duration.zero);
    }
    _lastReportedPosition = Duration.zero;
  }

  Future<void> seekToStart() async {
    await _audioPlayer.seek(Duration.zero);
    _lastReportedPosition = Duration.zero;
  }

  // ===========================================================================
  // SKIP NEXT / PREVIOUS
  // ===========================================================================

  Future<void> skipToNext() async {
    if (_allSurahs.isEmpty) return;

    final currentIndex = _audioPlayer.currentIndex ?? 0;
    int target = currentIndex + 1;

    if (target >= _allSurahs.length) {
      if (_repeatMode == RepeatStates.repeatAll) {
        target = 0;
      } else {
        return;
      }
    }

    _isChangingTrack = true;
    _ref?.read(selectedSurahIndexProvider.notifier).state = target;

    try {
      await _audioPlayer.seek(Duration.zero, index: target);
      _lastReportedPosition = Duration.zero;
    } finally {
      Future.delayed(const Duration(milliseconds: 250), () {
        _isChangingTrack = false;
      });
    }
  }

  Future<void> skipToPrevious() async {
    if (_allSurahs.isEmpty) return;

    final currentIndex = _audioPlayer.currentIndex ?? 0;
    int target = currentIndex - 1;

    if (target < 0) {
      if (_repeatMode == RepeatStates.repeatAll) {
        target = _allSurahs.length - 1;
      } else {
        return;
      }
    }

    _isChangingTrack = true;
    _ref?.read(selectedSurahIndexProvider.notifier).state = target;

    try {
      await _audioPlayer.seek(Duration.zero, index: target);
      _lastReportedPosition = Duration.zero;
    } finally {
      Future.delayed(const Duration(milliseconds: 250), () {
        _isChangingTrack = false;
      });
    }
  }

  // ===========================================================================
  // PLAY VERSE
  // ===========================================================================

  Future<void> playVerse({
    required Reciter reciter,
    required Surah surah,
    required int ayah,
  }) async {
    try {
      final session = await AudioSession.instance;
      await session.setActive(true);

      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      }

      await _ayahPlayer.stop();

      final directory = await getApplicationDocumentsDirectory();

      final source = await buildUrl(
        surah: surah,
        ayah: ayah,
        reciter: reciter,
        dirPath: directory.path,
      );

      await _ayahPlayer.setLoopMode(LoopMode.off);
      await _ayahPlayer.setAudioSource(source, initialPosition: Duration.zero);

      _publishCurrentAyah(surah.number, ayah);

      unawaited(_ayahPlayer.play());
    } on PlayerInterruptedException {
      debugPrint('playVerse: PlayerInterruptedException handled.');
    } catch (e, stack) {
      debugPrint('playVerse error: $e\n$stack');
      rethrow;
    }
  }

  void _publishCurrentAyah(int surahNumber, int ayah) {
    final ref = _ref;
    if (ref == null) return;

    final page = quran.getPageNumber(surahNumber, ayah);
    final current = ref.read(currentPlayingAyahProvider);

    ref.read(currentPlayingAyahProvider.notifier).state = AyahIdentifier(
      surah: surahNumber,
      ayah: ayah,
      page: page,
    );

    if (current?.page != page) {
      ref.read(jumpToPageProvider.notifier).state = page;
    }
  }

  // ===========================================================================
  // AUDIO SOURCES & DOWNLOADS
  // ===========================================================================

  Future<AudioSource> _buildSingleAudioSource(
      Surah surah,
      Reciter reciter,
      String dirPath,
      ) async {
    final surahStr = surah.number.toString().padLeft(3, '0');
    final fileName = '$surahStr.mp3';
    final localPath = '$dirPath/${reciter.audioFolder}/$fileName';

    final cleanBaseUrl = reciter.serverUrl.endsWith('/')
        ? reciter.serverUrl.substring(0, reciter.serverUrl.length - 1)
        : reciter.serverUrl;
    final url = '$cleanBaseUrl/$fileName';

    final mediaItem = MediaItem(
      id: '${surah.number}',
      album: surah.translation,
      title: 'Surah ${surah.nameEnglish}',
      artist: reciter.name,
    );

    if (await File(localPath).exists()) {
      return AudioSource.file(localPath, tag: mediaItem);
    }

    return AudioSource.uri(Uri.parse(url), tag: mediaItem);
  }

  Future<AudioSource> buildUrl({
    required Surah surah,
    required int ayah,
    required Reciter reciter,
    required String dirPath,
  }) async {
    final surahStr = surah.number.toString().padLeft(3, '0');
    final ayahStr = ayah.toString().padLeft(3, '0');
    final page = quran.getPageNumber(surah.number, ayah);

    final fileName = '$surahStr$ayahStr.mp3';

    final baseUrl = reciter.ayahServerUrl ??
        'https://everyayah.com/data/${reciter.audioFolder}';
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    final targetFolder = reciter.ayahAudioFolder ?? '${reciter.audioFolder}_ayahs';
    final localPath = '$dirPath/$targetFolder/$fileName';
    final url = '$cleanBaseUrl/$fileName';

    final mediaItem = MediaItem(
      id: '${surah.number}:$ayah:$page',
      album: surah.translation,
      title: 'Verse $ayah',
      artist: reciter.name,
    );

    if (await File(localPath).exists()) {
      return AudioSource.file(localPath, tag: mediaItem);
    }

    return AudioSource.uri(Uri.parse(url), tag: mediaItem);
  }

  Future<void> downloadSurah({
    required Reciter reciter,
    required Surah surah,
  }) async {
    final directory = await getApplicationDocumentsDirectory();

    final surahStr = surah.number.toString().padLeft(3, '0');
    final fileName = '$surahStr.mp3';
    final localPath = '${directory.path}/${reciter.audioFolder}/$fileName';

    final cleanBaseUrl = reciter.serverUrl.endsWith('/')
        ? reciter.serverUrl.substring(0, reciter.serverUrl.length - 1)
        : reciter.serverUrl;
    final url = '$cleanBaseUrl/$fileName';

    if (await File(localPath).exists()) {
      return;
    }

    await _startBackgroundDownload(url, localPath);
  }

  Future<void> _startBackgroundDownload(
      String url,
      String savePath,
      ) async {
    if (_downloadingTasks.contains(savePath)) {
      return;
    }

    try {
      final file = File(savePath);
      if (await file.exists()) {
        return;
      }

      _downloadingTasks.add(savePath);
      await file.parent.create(recursive: true);

      final tempPath = '$savePath.temp';
      await Dio().download(url, tempPath, deleteOnError: true);

      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.rename(savePath);
      }
    } catch (e) {
      final tempFile = File('$savePath.temp');
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      debugPrint('Background audio download error: $e');
    } finally {
      _downloadingTasks.remove(savePath);
    }
  }

  // ===========================================================================
  // AUDIO SESSION & RESET & DISPOSE
  // ===========================================================================

  Future<void> configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
        AVAudioSessionCategoryOptions.mixWithOthers,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      ),
    );
  }

  Future<void> reset() async {
    await _audioPlayer.stop();
    await _ayahPlayer.stop();
    await _audioPlayer.clearAudioSources();

    _hasLoadedSurah = false;
    _allSurahs = const [];
    _lastReportedPosition = Duration.zero;
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
    await _ayahPlayer.setVolume(volume);
  }

  void dispose() {
    _currentIndexSubscription?.cancel();
    _positionSubscription?.cancel();
    _audioPlayer.dispose();
    _ayahPlayer.dispose();
  }
}