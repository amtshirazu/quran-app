import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AyahTimingRecord {
  final int ayahNumber;
  final int timestampFrom;
  final int timestampTo;

  const AyahTimingRecord({
    required this.ayahNumber,
    required this.timestampFrom,
    required this.timestampTo,
  });
}

class AudioTimingService {
  static final AudioTimingService instance = AudioTimingService._init();
  AudioTimingService._init();

  Database? _db;
  final String dbFileName = "audio_timestamps.db";

  // In-memory timing cache for active Surah
  String? _cachedReciterId;
  int? _cachedSurahNumber;
  List<AyahTimingRecord>? _cachedVerses;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbFileName);

    final exists = await databaseExists(path);

    if (!exists) {
      try {
        final assetPath = 'assets/database/$dbFileName';
        await Directory(dirname(path)).create(recursive: true);

        ByteData data = await rootBundle.load(assetPath);
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        debugPrint(
          'AudioTimingService: Error copying audio_timestamps.db from assets: $e',
        );
        rethrow;
      }
    }

    return await openDatabase(path, readOnly: true);
  }

  /// Fetches and caches timing records for a given reciter and Surah.
  /// Subsequent position updates for the same Surah hit the in-memory cache directly.
  Future<List<AyahTimingRecord>> _getVersesForSurah(
    String reciterId,
    int surahNumber,
  ) async {
    if (_cachedReciterId == reciterId &&
        _cachedSurahNumber == surahNumber &&
        _cachedVerses != null) {
      return _cachedVerses!;
    }

    try {
      final db = await database;
      final rows = await db.query(
        'ayah_timestamps',
        columns: ['ayah_number', 'timestamp_from', 'timestamp_to'],
        where: 'reciter_id = ? AND surah_number = ?',
        whereArgs: [reciterId, surahNumber],
        orderBy: 'ayah_number ASC',
      );

      final records = rows
          .map(
            (r) => AyahTimingRecord(
              ayahNumber: r['ayah_number'] as int,
              timestampFrom: r['timestamp_from'] as int,
              timestampTo: r['timestamp_to'] as int,
            ),
          )
          .toList();

      _cachedReciterId = reciterId;
      _cachedSurahNumber = surahNumber;
      _cachedVerses = records;
      return records;
    } catch (e, stack) {
      debugPrint('AudioTimingService _getVersesForSurah error: $e\n$stack');
      return const [];
    }
  }

  /// Clears the in-memory timing cache.
  void clearCache() {
    _cachedReciterId = null;
    _cachedSurahNumber = null;
    _cachedVerses = null;
  }

  /// Finds the active Ayah number for a given reciter, surah, and playback position (in milliseconds).
  Future<int?> getActiveAyah({
    required String reciterId,
    required int surahNumber,
    required int positionMillis,
  }) async {
    final verses = await _getVersesForSurah(reciterId, surahNumber);
    if (verses.isEmpty) return null;

    // 1. Position before first verse
    if (positionMillis < verses.first.timestampFrom) {
      return verses.first.ayahNumber;
    }

    // 2. Position after last verse
    if (positionMillis >= verses.last.timestampTo) {
      return verses.last.ayahNumber;
    }

    // 3. Precise range match: [timestampFrom, timestampTo)
    for (final verse in verses) {
      if (positionMillis >= verse.timestampFrom &&
          positionMillis < verse.timestampTo) {
        return verse.ayahNumber;
      }
    }

    // 4. Fallback for gaps between verses: find nearest preceding verse
    for (int i = verses.length - 1; i >= 0; i--) {
      if (positionMillis >= verses[i].timestampFrom) {
        return verses[i].ayahNumber;
      }
    }

    return null;
  }

  /// Retrieves the start timestamp (in milliseconds) for a specific Ayah.
  Future<int?> getAyahStartTimestamp({
    required String reciterId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final verses = await _getVersesForSurah(reciterId, surahNumber);
    if (verses.isEmpty) return null;

    for (final verse in verses) {
      if (verse.ayahNumber == ayahNumber) {
        return verse.timestampFrom;
      }
    }

    return null;
  }
}
