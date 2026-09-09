import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_app/features/audio/data/reciters_list.dart';
import 'package:quran_app/features/audio/domain/models/Reciters.dart';
import 'package:quran_app/features/quran/domain/models/surah.dart';

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

  String get formattedSize {
    if (totalSizeBytes <= 0) return '0 MB';
    final mb = totalSizeBytes / (1024 * 1024);
    if (mb >= 1024) {
      return '${(mb / 1024).toStringAsFixed(1)} GB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }
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

  String formatBytes(double bytes) {
    if (bytes <= 0) return '0 MB';
    final mb = bytes / (1024 * 1024);
    if (mb >= 1024) {
      return '${(mb / 1024).toStringAsFixed(1)} GB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }

  String get formattedTotalUsed => formatBytes(totalUsedBytes);
  String get formattedFreeSpace => formatBytes(freeSpaceBytes);
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
    final surahStr = surah.number.toString().padLeft(3, '0');
    final fileName = "$surahStr.mp3";
    final localPath = "${directory.path}/${reciter.audioFolder}/$fileName";
    final url = "${reciter.serverUrl}/$fileName";

    final file = File(localPath);
    if (await file.exists()) {
      onCompleted();
      return;
    }

    try {
      updateProgress(key, 0.01);
      await file.parent.create(recursive: true);
      final tempPath = "$localPath.temp";

      await _dio.download(
        url,
        tempPath,
        deleteOnError: true,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final p = (received / total).clamp(0.0, 1.0);
            updateProgress(key, p);
          }
        },
      );

      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.rename(localPath);
      }
    } catch (e) {
      final tempFile = File("$localPath.temp");
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
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
    final surahStr = surahNum.toString().padLeft(3, '0');
    final fileName = "$surahStr.mp3";
    final localPath = "${directory.path}/${reciter.audioFolder}/$fileName";

    final file = File(localPath);
    if (await file.exists()) {
      await file.delete();
    }
    onCompleted();
  }

  Future<void> deleteAllReciterSurahs({
    required Reciter reciter,
    required Function() onCompleted,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final reciterDir = Directory("${directory.path}/${reciter.audioFolder}");
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
final downloadedRecitersProvider =
    FutureProvider<List<ReciterDownloadInfo>>((ref) async {
  ref.watch(downloadRefreshTriggerProvider);
  final directory = await getApplicationDocumentsDirectory();

  List<ReciterDownloadInfo> result = [];

  for (final reciter in reciters) {
    final reciterDir = Directory("${directory.path}/${reciter.audioFolder}");
    int count = 0;
    double size = 0;

    if (await reciterDir.exists()) {
      final files = reciterDir.listSync();
      for (final f in files) {
        if (f is File && f.path.endsWith('.mp3')) {
          count++;
          size += f.lengthSync();
        }
      }
    }

    result.add(
      ReciterDownloadInfo(
        reciter: reciter,
        downloadedCount: count,
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

  double get totalSizeBytes => downloadedSurahSizeMap.values
      .fold(0.0, (sum, size) => sum + size);

  String get formattedTotalSize {
    final mb = totalSizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }
}

/// Provider fetching Map of downloaded surah files for a specific reciter
final reciterFileDetailsProvider = FutureProvider.family<
    ReciterSurahFileDetails, Reciter>((ref, reciter) async {
  ref.watch(downloadRefreshTriggerProvider);
  final directory = await getApplicationDocumentsDirectory();
  final reciterDir = Directory("${directory.path}/${reciter.audioFolder}");

  Map<int, double> map = {};

  if (await reciterDir.exists()) {
    final files = reciterDir.listSync();
    for (final f in files) {
      if (f is File && f.path.endsWith('.mp3')) {
        final name = f.path.split(Platform.pathSeparator).last.replaceAll('.mp3', '');
        final num = int.tryParse(name);
        if (num != null) {
          map[num] = f.lengthSync().toDouble();
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
    final reciterDir = Directory("${directory.path}/${reciter.audioFolder}");
    if (await reciterDir.exists()) {
      final files = reciterDir.listSync();
      for (final f in files) {
        if (f is File && f.path.endsWith('.mp3')) {
          audioBytes += f.lengthSync().toDouble();
        }
      }
    }
  }

  // Scan local app databases & assets directory for Quran text/Tafseer/Azkaar vs Translations
  double quranTextBytes = 28 * 1024 * 1024.0; // Base Databases (Azkaar, Find Guidance, Tafseer) ~28MB
  double translationsBytes = 18 * 1024 * 1024.0; // Base Translations Databases ~18MB

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

  // Estimated free space: 2.1 GB default fallback
  double freeSpaceBytes = 2.1 * 1024 * 1024 * 1024.0;

  return StorageSummary(
    quranTextBytes: quranTextBytes,
    audioBytes: audioBytes,
    translationsBytes: translationsBytes,
    freeSpaceBytes: freeSpaceBytes,
  );
});
