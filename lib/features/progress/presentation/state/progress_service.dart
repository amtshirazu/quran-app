import 'package:sqflite/sqflite.dart';
import 'package:quran_app/core/database/database_helper.dart';
import '../../../quran/presentation/widgets/ayah_details_widget/paged/paged_surah_map.dart';
import 'package:quran/quran.dart' as quran;

class ProgressService {
  final dbHelper = DatabaseHelper.instance;
  static const int _minQuranPage = 1;
  static const int _maxQuranPage = 604;

  // ========================= HELPER =========================

  /// Accurately extracts all (surah, ayah) pairs from a Mushaf page
  List<({int surah, int ayah})> _getVersesOnPage(int page) {
    if (page < _minQuranPage || page > _maxQuranPage) return const [];

    final List<({int surah, int ayah})> verses = [];
    final rawList = quran.getPageData(page);

    for (final item in rawList) {
      final surahNum = (item['surah'] ?? item['surah_number']) as int?;
      final start = (item['start'] ?? item['ayah'] ?? item['start_ayah']) as int?;
      final end = (item['end'] ?? item['ayah'] ?? item['end_ayah']) as int?;

      if (surahNum != null && start != null && end != null) {
        for (int a = start; a <= end; a++) {
          verses.add((surah: surahNum, ayah: a));
        }
      }
    }
    return verses;
  }

  // ========================= APP INSTALL / FIRST OPEN DATE =========================

  /// Retrieves or initializes the date when the user first installed and opened the app
  Future<DateTime> getOrInitAppInstallDate() async {
    final saved = await dbHelper.getSetting('app_install_date');
    if (saved != null) {
      final parsed = DateTime.tryParse(saved);
      if (parsed != null) return parsed;
    }

    final firstReading = await getFirstReadingDate();
    final installDate = firstReading ?? DateTime.now();

    await dbHelper.setSetting('app_install_date', installDate.toIso8601String());
    return installDate;
  }

  // ========================= IMMEDIATE BOOKMARK (0s) =========================

  /// Instantly records current reading location so Continue Reading always
  /// knows where the user landed, even if they stay for less than the dwell threshold.
  Future<void> setBookmarkImmediate({
    required String mode,
    int? surahId,
    int? ayah,
    int? page,
  }) async {
    final db = await dbHelper.database;

    final resolvedSurahId = await resolveActiveSurah(
      mode: mode,
      surahId: surahId,
      page: page,
    ) ?? surahId;

    final now = DateTime.now().toIso8601String();

    await db.insert(
      'last_read',
      {
        'id': 1,
        'surah_id': resolvedSurahId,
        'ayah': ayah,
        'page': page,
        'mode': mode,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ========================= VERIFIED PROGRESS TRACKING (DWELL TIMER) =========================

  /// Called ONLY when the dwell timer expires (3s)
  Future<void> trackAyah(int surahId, int ayah) async {
    final db = await dbHelper.database;
    final now = DateTime.now().toIso8601String();

    await db.insert('reading_sessions', {
      'mode': 'ayah',
      'surah_id': surahId,
      'ayah': ayah,
      'page': null,
      'timestamp': now,
    });

    await setBookmarkImmediate(surahId: surahId, ayah: ayah, mode: 'ayah');
  }

  /// Called ONLY when the dwell timer expires (30s)
  Future<void> trackPage(int page) async {
    if (page < _minQuranPage || page > _maxQuranPage) return;

    final db = await dbHelper.database;
    final now = DateTime.now().toIso8601String();

    final activeSurahId = await resolveActiveSurah(
      mode: 'page',
      page: page,
    );

    await db.insert('reading_sessions', {
      'mode': 'page',
      'surah_id': activeSurahId,
      'ayah': null,
      'page': page,
      'timestamp': now,
    });

    await setBookmarkImmediate(surahId: activeSurahId, page: page, mode: 'page');
  }

  // ========================= STREAK =========================

  Future<void> updateStreak() async {
    try {
      final db = await dbHelper.database;

      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      final result = await db.query('streak', limit: 1);

      if (result.isEmpty) {
        await db.insert(
          'streak',
          {
            'id': 1,
            'last_read_date': todayDate.toIso8601String(),
            'current_streak': 1,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        return;
      }

      final data = result.first;
      final lastReadDateStr = data['last_read_date'] as String?;
      int currentStreak = (data['current_streak'] as int?) ?? 0;

      if (lastReadDateStr == null) {
        await db.insert(
          'streak',
          {
            'id': 1,
            'last_read_date': todayDate.toIso8601String(),
            'current_streak': 1,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        return;
      }

      final lastReadDate = DateTime.parse(lastReadDateStr).toLocal();
      final lastDate = DateTime(
        lastReadDate.year,
        lastReadDate.month,
        lastReadDate.day,
      );

      final difference = todayDate.difference(lastDate).inDays;

      if (difference == 1) {
        currentStreak += 1;
      } else if (difference > 1) {
        currentStreak = 1;
      } else {
        return; // already recorded today
      }

      await db.insert(
        'streak',
        {
          'id': 1,
          'last_read_date': todayDate.toIso8601String(),
          'current_streak': currentStreak,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }

  Future<int?> getCurrentStreak() async {
    final db = await dbHelper.database;
    final result = await db.query('streak', limit: 1);
    if (result.isEmpty) return 0;
    return (result.first['current_streak'] as int?) ?? 0;
  }

  // ========================= LAST READ =========================

  Future<void> clearLastRead() async {
    final db = await dbHelper.database;
    await db.delete('last_read');
  }

  Future<Map<String, dynamic>?> getLastRead() async {
    final db = await dbHelper.database;
    final result = await db.query(
      'last_read',
      orderBy: 'updated_at DESC, id DESC',
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first;
  }

  // ========================= PROGRESS FOR LAST READ SURAH =========================

  Future<double?> getSurahProgress({
    required int surahId,
    required int totalAyahs,
  }) async {
    final db = await dbHelper.database;

    final rows = await db.query(
      'reading_sessions',
      where: 'surah_id = ?',
      whereArgs: [surahId],
    );

    if (rows.isEmpty) {
      final lastReadRows = await db.query(
        'last_read',
        where: 'surah_id = ?',
        whereArgs: [surahId],
      );
      if (lastReadRows.isEmpty) return 0.0;

      final Set<int> initialAyahs = {};
      for (final r in lastReadRows) {
        if (r['mode'] == 'ayah' && r['ayah'] != null) {
          initialAyahs.add(r['ayah'] as int);
        } else if (r['mode'] == 'page' && r['page'] != null) {
          final versesOnPage = _getVersesOnPage(r['page'] as int);
          for (final v in versesOnPage) {
            if (v.surah == surahId) initialAyahs.add(v.ayah);
          }
        }
      }
      return totalAyahs <= 0 ? 0.0 : (initialAyahs.length / totalAyahs).clamp(0.0, 1.0);
    }

    final Set<int> uniqueAyahs = {};

    for (final row in rows) {
      final mode = row['mode'] as String?;

      if (mode == 'ayah') {
        final ayah = row['ayah'] as int?;
        if (ayah != null) uniqueAyahs.add(ayah);
      } else if (mode == 'page') {
        final page = row['page'] as int?;
        if (page != null) {
          final versesOnPage = _getVersesOnPage(page);
          for (final v in versesOnPage) {
            if (v.surah == surahId) {
              uniqueAyahs.add(v.ayah);
            }
          }
        }
      }
    }

    if (totalAyahs <= 0) return 0.0;
    return (uniqueAyahs.length / totalAyahs).clamp(0.0, 1.0);
  }

  // ========================= RESOLVE ACTIVE SURAH =========================

  Future<int?> resolveActiveSurah({
    required String mode,
    int? surahId,
    int? page,
  }) async {
    if (mode == 'ayah') return surahId;
    if (mode != 'page' || page == null) return null;

    final verses = _getVersesOnPage(page);
    if (verses.isEmpty) return null;

    final uniqueSurahs = verses.map((v) => v.surah).toSet().toList();
    if (uniqueSurahs.length == 1) {
      return uniqueSurahs.first;
    }

    final newSurah = verses.firstWhere(
          (v) => v.ayah == 1,
      orElse: () => verses.first,
    );

    return newSurah.surah;
  }

  // ========================= OVERALL STATS (SESSIONS TABLE) =========================

  Future<int?> getSurahsCompleted(List<dynamic> surahs) async {
    int completedSurahs = 0;

    for (final surah in surahs) {
      final progress = await _calculateSurahsProgress(
        surahId: surah.number,
        totalAyahs: surah.totalAyahs,
      );

      if (progress != null && progress >= 1.0) {
        completedSurahs++;
      }
    }

    return completedSurahs;
  }

  Future<double?> _calculateSurahsProgress({
    required int surahId,
    required int totalAyahs,
  }) async {
    final db = await dbHelper.database;
    final Set<int> uniqueAyahs = {};

    final ayahResult = await db.rawQuery(
      "SELECT DISTINCT ayah FROM reading_sessions WHERE mode = 'ayah' AND surah_id = ?",
      [surahId],
    );

    for (final row in ayahResult) {
      final ayah = row['ayah'] as int?;
      if (ayah != null) uniqueAyahs.add(ayah);
    }

    final range = surahPageRanges[surahId];
    if (range != null) {
      final pageResult = await db.rawQuery(
        "SELECT DISTINCT page FROM reading_sessions WHERE mode = 'page' AND page BETWEEN ? AND ?",
        [range.start, range.end],
      );

      for (final row in pageResult) {
        final page = row['page'] as int?;
        if (page != null) {
          final versesOnPage = _getVersesOnPage(page);
          for (final v in versesOnPage) {
            if (v.surah == surahId) {
              uniqueAyahs.add(v.ayah);
            }
          }
        }
      }
    }

    return totalAyahs == 0
        ? 0.0
        : (uniqueAyahs.length / totalAyahs).clamp(0.0, 1.0);
  }

  Future<double> getQuranProgress() async {
    final totalReadAyahs = await getTotalVersesRead();
    const totalAyahs = 6236;
    return (totalReadAyahs / totalAyahs).clamp(0.0, 1.0);
  }

  Future<int> getTotalVersesRead() async {
    final db = await dbHelper.database;
    final Set<String> uniqueAyahs = {};

    final ayahResult = await db.rawQuery(
      "SELECT DISTINCT surah_id, ayah FROM reading_sessions WHERE mode = 'ayah'",
    );

    for (final row in ayahResult) {
      final surah = row['surah_id'];
      final ayah = row['ayah'];
      if (surah != null && ayah != null) {
        uniqueAyahs.add('$surah-$ayah');
      }
    }

    final pageResult = await db.rawQuery(
      "SELECT DISTINCT page FROM reading_sessions WHERE mode = 'page'",
    );

    for (final row in pageResult) {
      final page = row['page'] as int?;
      if (page != null) {
        final versesOnPage = _getVersesOnPage(page);
        for (final v in versesOnPage) {
          uniqueAyahs.add('${v.surah}-${v.ayah}');
        }
      }
    }

    return uniqueAyahs.length;
  }

  Future<DateTime?> getFirstReadingDate() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT timestamp
      FROM reading_sessions
      ORDER BY timestamp ASC
      LIMIT 1
    ''');

    if (result.isEmpty) return null;
    final raw = result.first['timestamp'] as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> clearAllReadingHistory() async {
    final db = await dbHelper.database;
    await db.delete('reading_sessions');
    await db.delete('last_read');
  }
}
