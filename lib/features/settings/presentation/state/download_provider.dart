import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storage_space/storage_space.dart';
import 'package:quran_app/features/audio/data/reciters_list.dart';
import 'package:quran_app/features/audio/domain/models/Reciters.dart';
import 'package:quran_app/features/quran/domain/models/surah.dart';

/// Formats byte sizes dynamically: shows MB below 1000 MB, and GB (1.1 GB, 1.23 GB) above 1000 MB
String formatBytesHelper(double bytes) {
  if (bytes <= 0) return '0 MB';
  final mb = bytes / (1024 * 1024);
  if (mb >= 1000) {
    final gb = mb / 1024.0;
    final formatted = gb
        .toStringAsFixed(gb >= 10 ? 1 : 2)
        .replaceAll(RegExp(r'\.?0+$'), '');
    return '$formatted GB';
  }
  return '${mb.toStringAsFixed(1)} MB';
}

class ReciterDownloadInfo {
  final Reciter reciter;
  final int downloadedCount;
  final int totalSurahs;
  final double totalSizeBytes;
  final bool isDownloading;
  final double currentProgress;
  final int? currentDownloadingSurahNum;

  ReciterDownloadInfo({
    required this.reciter,
    required this.downloadedCount,
    this.totalSurahs = 114,
    required this.totalSizeBytes,
    this.isDownloading = false,
    this.currentProgress = 0.0,
    this.currentDownloadingSurahNum,
  });

  String get formattedSize => formatBytesHelper(totalSizeBytes);
}

class StorageSummary {
  final double quranTextBytes;
  final double audioBytes;
  final double translationsBytes;
  final double freeSpaceBytes;

  StorageSummary({
    required this.quranTextBytes,
    required this.audioBytes,
    required this.translationsBytes,
    required this.freeSpaceBytes,
  });

  double get totalUsedBytes => quranTextBytes + audioBytes + translationsBytes;

  String get formattedTotalUsed => formatBytesHelper(totalUsedBytes);
  String get formattedFreeSpace => formatBytesHelper(freeSpaceBytes);
}

class DownloadManagerNotifier extends StateNotifier<Map<String, double>> {
  DownloadManagerNotifier() : super({});

  final Dio _dio = Dio();

  void updateProgress(String key, double progress) {
    state = {...state, key: progress};
  }

  void clearProgress(String key) {
    final copy = Map<String, double>.from(state);
    copy.remove(key);
    state = copy;
  }

  Future<void> downloadSurah({
    required Reciter reciter,
    required Surah surah,
    required Function() onCompleted,
  }) async {
    final key = '${reciter.id}_${surah.number}';
    final directory = await getApplicationDocumentsDirectory();
    final targetFolder =
        reciter.ayahAudioFolder ?? '${reciter.audioFolder}_ayahs';
    final folderPath = "${directory.path}/$targetFolder";

    final baseUrl =
        reciter.ayahServerUrl ??
        'https://everyayah.com/data/${reciter.audioFolder}';
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    try {
      updateProgress(key, 0.0);
      final totalAyahs = surah.totalAyahs;
      final surahStr = surah.number.toString().padLeft(3, '0');

      for (int i = 1; i <= totalAyahs; i++) {
        final ayahStr = i.toString().padLeft(3, '0');
        final fileName = "$surahStr$ayahStr.mp3";
        final localPath = "$folderPath/$fileName";
        final url = "$cleanBaseUrl/$fileName";

        final file = File(localPath);
        if (!await file.exists()) {
          await file.parent.create(recursive: true);
          final tempPath = "$localPath.temp";

          try {
            await _dio.download(url, tempPath, deleteOnError: true);
            final tempFile = File(tempPath);
            if (await tempFile.exists()) {
              await tempFile.rename(localPath);
            }
          } catch (_) {}
        }

        final progress = (i / totalAyahs).clamp(0.0, 1.0);
        updateProgress(key, progress);
      }
    } catch (_) {
    } finally {
      clearProgress(key);
      onCompleted();
    }
  }

  Future<void> deleteSurah({
    required Reciter reciter,
    required int surahNum,
    required Function() onCompleted,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final targetFolder =
        reciter.ayahAudioFolder ?? '${reciter.audioFolder}_ayahs';
    final folderPath = "${directory.path}/$targetFolder";
    final surahStr = surahNum.toString().padLeft(3, '0');

    final dir = Directory(folderPath);
    if (await dir.exists()) {
      final files = dir.listSync();
      for (final f in files) {
        if (f is File &&
            f.path.split(Platform.pathSeparator).last.startsWith(surahStr)) {
          await f.delete();
        }
      }
    }
    onCompleted();
  }

  Future<void> deleteAllReciterSurahs({
    required Reciter reciter,
    required Function() onCompleted,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final targetFolder =
        reciter.ayahAudioFolder ?? '${reciter.audioFolder}_ayahs';
    final reciterDir = Directory("${directory.path}/$targetFolder");
    if (await reciterDir.exists()) {
      await reciterDir.delete(recursive: true);
    }
    onCompleted();
  }
}

final downloadManagerProvider =
    StateNotifierProvider<DownloadManagerNotifier, Map<String, double>>((ref) {
      return DownloadManagerNotifier();
    });

/// Refreshes download stats trigger
final downloadRefreshTriggerProvider = StateProvider<int>((ref) => 0);

/// Provider fetching ALL reciters download info summaries
final downloadedRecitersProvider = FutureProvider<List<ReciterDownloadInfo>>((
  ref,
) async {
  ref.watch(downloadRefreshTriggerProvider);
  final directory = await getApplicationDocumentsDirectory();

  List<ReciterDownloadInfo> result = [];

  for (final reciter in reciters) {
    final targetFolder =
        reciter.ayahAudioFolder ?? '${reciter.audioFolder}_ayahs';
    final reciterDir = Directory("${directory.path}/$targetFolder");
    final Set<int> downloadedSurahs = {};
    double size = 0;

    if (await reciterDir.exists()) {
      final files = reciterDir.listSync();
      for (final f in files) {
        if (f is File && f.path.endsWith('.mp3')) {
          final fileName = f.path
              .split(Platform.pathSeparator)
              .last
              .replaceAll('.mp3', '');
          if (fileName.length >= 6) {
            final surahNum = int.tryParse(fileName.substring(0, 3));
            if (surahNum != null) {
              downloadedSurahs.add(surahNum);
            }
          }
          size += f.lengthSync();
        }
      }
    }

    result.add(
      ReciterDownloadInfo(
        reciter: reciter,
        downloadedCount: downloadedSurahs.length,
        totalSizeBytes: size,
      ),
    );
  }

  return result;
});

class ReciterSurahFileDetails {
  final Map<int, double> downloadedSurahSizeMap;
  ReciterSurahFileDetails(this.downloadedSurahSizeMap);

  int get downloadedCount => downloadedSurahSizeMap.length;

  double get totalSizeBytes =>
      downloadedSurahSizeMap.values.fold(0.0, (sum, size) => sum + size);

  String get formattedTotalSize => formatBytesHelper(totalSizeBytes);
}

/// Provider fetching Map of downloaded surah files for a specific reciter
final reciterFileDetailsProvider =
    FutureProvider.family<ReciterSurahFileDetails, Reciter>((
      ref,
      reciter,
    ) async {
      ref.watch(downloadRefreshTriggerProvider);
      final directory = await getApplicationDocumentsDirectory();
      final targetFolder =
          reciter.ayahAudioFolder ?? '${reciter.audioFolder}_ayahs';
      final reciterDir = Directory("${directory.path}/$targetFolder");

      Map<int, double> map = {};

      if (await reciterDir.exists()) {
        final files = reciterDir.listSync();
        for (final f in files) {
          if (f is File && f.path.endsWith('.mp3')) {
            final fileName = f.path
                .split(Platform.pathSeparator)
                .last
                .replaceAll('.mp3', '');
            if (fileName.length >= 6) {
              final surahNum = int.tryParse(fileName.substring(0, 3));
              if (surahNum != null) {
                map[surahNum] =
                    (map[surahNum] ?? 0.0) + f.lengthSync().toDouble();
              }
            }
          }
        }
      }

      return ReciterSurahFileDetails(map);
    });

/// Provider fetching real calculated storage summary
final storageSummaryProvider = FutureProvider<StorageSummary>((ref) async {
  ref.watch(downloadRefreshTriggerProvider);
  ref.watch(downloadManagerProvider);
  final directory = await getApplicationDocumentsDirectory();

  double audioBytes = 0.0;
  for (final reciter in reciters) {
    final targetFolder =
        reciter.ayahAudioFolder ?? '${reciter.audioFolder}_ayahs';
    final reciterDir = Directory("${directory.path}/$targetFolder");
    if (await reciterDir.exists()) {
      final files = reciterDir.listSync();
      for (final f in files) {
        if (f is File && f.path.endsWith('.mp3')) {
          audioBytes += f.lengthSync().toDouble();
        }
      }
    }
  }

  // Base text and translation databases
  double quranTextBytes = 28 * 1024 * 1024.0;
  double translationsBytes = 18 * 1024 * 1024.0;

  try {
    final dbDir = Directory("${directory.path}/databases");
    if (await dbDir.exists()) {
      for (final entity in dbDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.db')) {
          final size = entity.lengthSync().toDouble();
          if (entity.path.contains('translations')) {
            translationsBytes += size;
          } else {
            quranTextBytes += size;
          }
        }
      }
    }
  } catch (_) {}

  // REAL HARDWARE DISK CHECK
  double freeSpaceBytes = 0.0;
  try {
    final space = await getStorageSpace(
      lowOnSpaceThreshold: 1024 * 1024 * 500, // 500 MB threshold
      fractionDigits: 1,
    );
    freeSpaceBytes = space.free.toDouble();
  } catch (_) {
    freeSpaceBytes = 0.0;
  }

  return StorageSummary(
    quranTextBytes: quranTextBytes,
    audioBytes: audioBytes,
    translationsBytes: translationsBytes,
    freeSpaceBytes: freeSpaceBytes,
  );
});
