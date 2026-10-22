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
import 'package:quran_app/features/audio/data/audio_timing_service.dart';
import 'package:quran_app/features/audio/data/audio_artwork_helper.dart';
import 'package:quran_app/features/audio/presentation/state/repeat_states.dart';

import '../../../quran/domain/models/surah.dart';
import '../../../quran/presentation/state/quran_providers.dart';
import '../../domain/models/Reciters.dart';
import 'audio_providers.dart';

class QuranAudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _ayahPlayer = AudioPlayer();

  final Set<String> _downloadingTasks = {};

  StreamSubscription<int?>? _currentIndexSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;

  Ref? _ref;
  bool _initialized = false;
  bool _hasLoadedSurah = false;
  bool _isChangingTrack = false;
  bool _isHandlingCompletion = false;

  int _playOperationToken = 0;
  int _timingGeneration = 0;

  RepeatStates _repeatMode = RepeatStates.off;

  List<Surah> _allSurahs = const [];
  Surah? _currentSurah;
  Reciter? _reciter;
  int _activeSurahIndex = 0;

  bool get hasLoadedSurah => _hasLoadedSurah;
  bool get isPlaying => _audioPlayer.playing;
  AudioPlayer get player => _audioPlayer;
  AudioPlayer get ayahPlayer => _ayahPlayer;
  Reciter? get currentReciter => _reciter;
  Surah? get currentSurah => _currentSurah;

  Future<void> init(Ref ref) async {
    if (_initialized) return;

    _initialized = true;
    _ref = ref;
    _repeatMode = ref.read(repeatModeProvider);

    await configureAudioSession();
    await _applyLoopMode();

    // 1. Sync active playing surah index & auto-advancement handling
    _currentIndexSubscription = _audioPlayer.currentIndexStream.listen((index) {
      if (index == null ||
          index < 0 ||
          _allSurahs.isEmpty ||
          index >= _allSurahs.length) {
        return;
      }

      if (_isChangingTrack) {
        _activeSurahIndex = index;
        _currentSurah = _allSurahs[index];
        _ref?.read(selectedSurahIndexProvider.notifier).state = index;
        _ref?.read(selectedSurahProvider.notifier).state = _allSurahs[index];
        return;
      }

      // Automatic track transition by just_audio
      if (index != _activeSurahIndex) {
        if (_repeatMode == RepeatStates.off) {
          // In Repeat OFF mode, automatically advancing to the next track is prevented.
          // Reset to the beginning of the surah that just finished and pause.
          unawaited(_preventAutoAdvancementAndReset(_activeSurahIndex));
        } else if (_repeatMode == RepeatStates.repeatAll) {
          _activeSurahIndex = index;
          _currentSurah = _allSurahs[index];
          _ref?.read(selectedSurahIndexProvider.notifier).state = index;
          _ref?.read(selectedSurahProvider.notifier).state = _allSurahs[index];
          _publishCurrentAyah(_allSurahs[index].number, 1);
        }
      }
    });

    // 2. Track completion handler (e.g. at the end of playlist / Surah 114)
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((
      playerState,
    ) {
      if (_isChangingTrack || _isHandlingCompletion) return;

      if (playerState.processingState == ProcessingState.completed) {
        unawaited(_handleTrackCompleted());
      }
    });

    // 3. Proportional Active Verse Sync
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (!_isChangingTrack && _audioPlayer.playing && _currentSurah != null) {
        _updateActiveVerseFromPosition(position);
      }
    });
  }

  Future<void> _preventAutoAdvancementAndReset(int finishedIndex) async {
    if (_isHandlingCompletion) return;
    _isHandlingCompletion = true;

    try {
      await _audioPlayer.pause();
      await _audioPlayer.seek(Duration.zero, index: finishedIndex);

      _activeSurahIndex = finishedIndex;
      if (finishedIndex < _allSurahs.length) {
        _currentSurah = _allSurahs[finishedIndex];
        _ref?.read(selectedSurahIndexProvider.notifier).state = finishedIndex;
        _ref?.read(selectedSurahProvider.notifier).state =
            _allSurahs[finishedIndex];
        _publishCurrentAyah(_allSurahs[finishedIndex].number, 1);
      }
    } catch (e) {
      debugPrint('Error handling auto advancement reset: $e');
    } finally {
      _isHandlingCompletion = false;
    }
  }

  Future<void> _handleTrackCompleted() async {
    if (_isHandlingCompletion) return;
    _isHandlingCompletion = true;

    try {
      final finishedIndex = _audioPlayer.currentIndex ?? _activeSurahIndex;

      if (_repeatMode == RepeatStates.off) {
        await _audioPlayer.pause();
        await _audioPlayer.seek(Duration.zero, index: finishedIndex);

        _activeSurahIndex = finishedIndex;
        if (finishedIndex < _allSurahs.length) {
          _currentSurah = _allSurahs[finishedIndex];
          _ref?.read(selectedSurahIndexProvider.notifier).state = finishedIndex;
          _ref?.read(selectedSurahProvider.notifier).state =
              _allSurahs[finishedIndex];
          _publishCurrentAyah(_allSurahs[finishedIndex].number, 1);
        }
      }
    } catch (e) {
      debugPrint('Error handling track completion: $e');
    } finally {
      _isHandlingCompletion = false;
    }
  }

  void _updateActiveVerseFromPosition(Duration position) {
    if (_isChangingTrack) return;
    final currentGen = _timingGeneration;
    final currentSurahNum = _currentSurah?.number;
    final currentReciterId = _reciter?.id;

    if (currentSurahNum == null || currentReciterId == null) return;
    final positionMillis = position.inMilliseconds;
    final activePlaying = _ref?.read(currentPlayingAyahProvider);

    AudioTimingService.instance
        .getActiveAyah(
          reciterId: currentReciterId,
          surahNumber: currentSurahNum,
          positionMillis: positionMillis,
        )
        .then((ayahNum) {
          // Stale lookup protection
          if (currentGen != _timingGeneration) return;
          if (_currentSurah?.number != currentSurahNum ||
              _reciter?.id != currentReciterId) {
            return;
          }
          if (!_audioPlayer.playing && !_ayahPlayer.playing) return;

          // Guard against transient 0ms position emission when playback initializes at verse > 1
          if (positionMillis < 500 &&
              activePlaying != null &&
              activePlaying.surah == currentSurahNum &&
              activePlaying.ayah > 1 &&
              ayahNum == 1) {
            return;
          }

          if (ayahNum != null) {
            _publishCurrentAyah(currentSurahNum, ayahNum);
          }
        });
  }

  Future<void> updateRepeatMode(RepeatStates repeatMode) async {
    _repeatMode = repeatMode;
    _ref?.read(repeatModeProvider.notifier).state = repeatMode;
    await _applyLoopMode();
  }

  Future<void> _applyLoopMode() async {
    switch (_repeatMode) {
      case RepeatStates.repeatOne:
        await _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case RepeatStates.repeatAll:
        await _audioPlayer.setLoopMode(LoopMode.all);
        break;
      case RepeatStates.off:
        await _audioPlayer.setLoopMode(LoopMode.off);
        break;
    }
  }

  Future<void> playSurah({
    required Reciter reciter,
    required Surah surah,
    required List<Surah> allSurahs,
    int startAyah = 1,
  }) async {
    final opToken = ++_playOperationToken;
    _timingGeneration++;

    final session = await AudioSession.instance;
    await session.setActive(true);

    if (_ayahPlayer.playing) {
      await _ayahPlayer.stop();
    }

    final targetIndex = allSurahs.indexWhere((s) => s.number == surah.number);
    if (targetIndex == -1) {
      throw ArgumentError('Surah ${surah.number} not found in allSurahs.');
    }

    _isChangingTrack = true;

    final previousReciter = _reciter;
    _reciter = reciter;
    _allSurahs = allSurahs;
    _currentSurah = surah;
    _activeSurahIndex = targetIndex;

    _ref?.read(selectedSurahIndexProvider.notifier).state = targetIndex;
    _ref?.read(selectedSurahProvider.notifier).state = surah;

    await _applyLoopMode();

    final directory = await getApplicationDocumentsDirectory();

    if (opToken != _playOperationToken) return;

    int? initialStartMillis;
    if (startAyah > 1) {
      initialStartMillis = await AudioTimingService.instance
          .getAyahStartTimestamp(
            reciterId: reciter.id,
            surahNumber: surah.number,
            ayahNumber: startAyah,
          );
    }

    final initialPosition = initialStartMillis != null
        ? Duration(milliseconds: initialStartMillis)
        : Duration.zero;

    try {
      final isNewReciter =
          previousReciter == null || previousReciter.id != reciter.id;
      final isPlaylistEmpty = _audioPlayer.sequence.isEmpty;
      final isSequenceLengthMismatch =
          _audioPlayer.sequence.length != allSurahs.length;

      if (isNewReciter || isPlaylistEmpty || isSequenceLengthMismatch) {
        final sources = await Future.wait(
          allSurahs.map(
            (s) => _buildSingleAudioSource(s, reciter, directory.path),
          ),
        );

        if (opToken != _playOperationToken) return;

        await _audioPlayer.setAudioSources(
          sources,
          initialIndex: targetIndex,
          initialPosition: initialPosition,
        );
      } else {
        if (_audioPlayer.currentIndex != targetIndex ||
            initialStartMillis != null) {
          await _audioPlayer.seek(initialPosition, index: targetIndex);
        } else {
          await _audioPlayer.seek(Duration.zero);
        }
      }

      if (opToken != _playOperationToken) return;

      _hasLoadedSurah = true;

      _publishCurrentAyah(surah.number, startAyah);

      unawaited(_audioPlayer.play());
    } finally {
      if (opToken == _playOperationToken) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (opToken == _playOperationToken) {
            _isChangingTrack = false;
          }
        });
      }
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

  Future<void> play() async {
    unawaited(_audioPlayer.play());
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    _playOperationToken++;
    _timingGeneration++;

    await _audioPlayer.stop();
    await _ayahPlayer.stop();
    if (_audioPlayer.sequence.isNotEmpty) {
      await _audioPlayer.seek(Duration.zero, index: 0);
    }
    clearActiveState();
  }

  void clearActiveState() {
    _timingGeneration++;
    _currentSurah = null;
    AudioTimingService.instance.clearCache();
    _ref?.read(currentPlayingAyahProvider.notifier).state = null;
    _ref?.read(jumpToPageProvider.notifier).state = null;
    _ref?.read(targetAyahProvider.notifier).state = null;
  }

  Future<void> seekToStart() async {
    await _audioPlayer.seek(Duration.zero, index: 0);
  }

  Future<void> seekToAyah({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    if (_reciter == null ||
        _currentSurah == null ||
        _currentSurah!.number != surahNumber)
      return;

    final startMillis = await AudioTimingService.instance.getAyahStartTimestamp(
      reciterId: _reciter!.id,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );

    if (startMillis != null) {
      await _audioPlayer.seek(Duration(milliseconds: startMillis));
      _publishCurrentAyah(surahNumber, ayahNumber);
    }
  }

  Future<void> skipToNext() async {
    if (_allSurahs.isEmpty) return;

    final currentIndex = _audioPlayer.currentIndex ?? _activeSurahIndex;
    int target = currentIndex + 1;

    if (target >= _allSurahs.length) {
      if (_repeatMode == RepeatStates.repeatAll) {
        target = 0;
      } else {
        return;
      }
    }

    _isChangingTrack = true;
    _activeSurahIndex = target;
    _currentSurah = _allSurahs[target];

    _ref?.read(selectedSurahIndexProvider.notifier).state = target;
    _ref?.read(selectedSurahProvider.notifier).state = _allSurahs[target];

    try {
      await _audioPlayer.seek(Duration.zero, index: target);
      _publishCurrentAyah(_allSurahs[target].number, 1);
    } finally {
      Future.delayed(const Duration(milliseconds: 250), () {
        _isChangingTrack = false;
      });
    }
  }

  Future<void> skipToPrevious() async {
    if (_allSurahs.isEmpty) return;

    final currentIndex = _audioPlayer.currentIndex ?? _activeSurahIndex;
    int target = currentIndex - 1;

    if (target < 0) {
      if (_repeatMode == RepeatStates.repeatAll) {
        target = _allSurahs.length - 1;
      } else {
        return;
      }
    }

    _isChangingTrack = true;
    _activeSurahIndex = target;
    _currentSurah = _allSurahs[target];

    _ref?.read(selectedSurahIndexProvider.notifier).state = target;
    _ref?.read(selectedSurahProvider.notifier).state = _allSurahs[target];

    try {
      await _audioPlayer.seek(Duration.zero, index: target);
      _publishCurrentAyah(_allSurahs[target].number, 1);
    } finally {
      Future.delayed(const Duration(milliseconds: 250), () {
        _isChangingTrack = false;
      });
    }
  }

  Future<void> playVerse({
    required Reciter reciter,
    required Surah surah,
    required int ayah,
  }) async {
    _timingGeneration++;

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

      _currentSurah = surah;
      _reciter = reciter;

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
    if (_currentSurah == null || _currentSurah!.number != surahNumber) return;

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

  Future<AudioSource> _buildSingleAudioSource(
    Surah surah,
    Reciter reciter,
    String dirPath,
  ) async {
    final fileName = '${surah.number.toString().padLeft(3, '0')}.mp3';
    final localPath = '$dirPath/${reciter.audioFolder}/$fileName';

    final cleanBaseUrl = reciter.serverUrl.endsWith('/')
        ? reciter.serverUrl.substring(0, reciter.serverUrl.length - 1)
        : reciter.serverUrl;
    final url = '$cleanBaseUrl/$fileName';

    final artUri = await AudioArtworkHelper.getLocalAssetFileUri(reciter.image);

    final mediaItem = MediaItem(
      id: '${surah.number}',
      album: 'Surah ${surah.nameEnglish}',
      title: 'Surah ${surah.nameEnglish}',
      artist: reciter.name,
      artUri: artUri,
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

    final baseUrl =
        reciter.ayahServerUrl ??
        'https://everyayah.com/data/${reciter.audioFolder}';
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    final targetFolder =
        reciter.ayahAudioFolder ?? '${reciter.audioFolder}_ayahs';
    final localPath = '$dirPath/$targetFolder/$fileName';
    final url = '$cleanBaseUrl/$fileName';

    final mediaItem = MediaItem(
      id: '${surah.number}:$ayah:$page',
      album: 'Surah ${surah.nameEnglish}',
      title: 'Surah ${surah.nameEnglish}',
      artist: reciter.name,
      artUri: Uri.parse('asset:///${reciter.image}'),
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

    final fileName = '${surah.number.toString().padLeft(3, '0')}.mp3';
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

  Future<void> _startBackgroundDownload(String url, String savePath) async {
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
    _playOperationToken++;
    _timingGeneration++;

    await _audioPlayer.stop();
    await _ayahPlayer.stop();
    await _audioPlayer.clearAudioSources();

    _hasLoadedSurah = false;
    _allSurahs = const [];
    _currentSurah = null;
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
    await _ayahPlayer.setVolume(volume);
  }

  void dispose() {
    _currentIndexSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _audioPlayer.dispose();
    _ayahPlayer.dispose();
  }
}
