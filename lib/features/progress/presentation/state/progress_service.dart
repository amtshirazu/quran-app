import 'package:quran_app/core/database/database_helper.dart';
import 'package:quran_app/features/quran/data/repository/paged_repository.dart';
import '../../../quran/presentation/widgets/ayah_details_widget/paged/paged_surah_map.dart';

class ProgressService {
  final dbHelper = DatabaseHelper.instance;
  static const int _minQuranPage = 1;
  static const int _maxQuranPage = 604;

  // ========================= TRACKING =========================

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

    await _updateLastRead(surahId: surahId, ayah: ayah, mode: 'ayah');

    await _updateStreak();
  }

  Future<void> trackPage(int page) async {
    if (page < _minQuranPage || page > _maxQuranPage) return;

    final db = await dbHelper.database;

    final now = DateTime.now().toIso8601String();

    await db.insert('reading_sessions', {
      'mode': 'page',
      'surah_id': null, // 🔥 FIX
      'ayah': null,
      'page': page,
      'timestamp': now,
    });

    await _updateLastRead(page: page, mode: 'page');

    await _updateStreak();
  }

  // ========================= STREAK =========================

  Future<void> _updateStreak() async {
    final db = await dbHelper.database;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final result = await db.query('streak', limit: 1);

    if (result.isEmpty) {
      await db.insert('streak', {
        'id': 1,
        'last_read_date': todayDate.toIso8601String(),
        'current_streak': 1,
      });
      return;
    }

    final data = result.first;

    final lastReadDateStr = data['last_read_date'] as String?;
    int currentStreak = (data['current_streak'] as int?) ?? 0;

    if (lastReadDateStr == null) return;

    final lastReadDate = DateTime.parse(lastReadDateStr);
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
      return; // same day
    }

    await db.update(
      'streak',
      {
        'last_read_date': todayDate.toIso8601String(),
        'current_streak': currentStreak,
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<int?> getCurrentStreak() async {
    final db = await dbHelper.database;

    final result = await db.query('streak', limit: 1);

    if (result.isEmpty) return 0;

    return (result.first['current_streak'] as int?) ?? 0;
  }

  // ========================= LAST READ =========================

  Future<void> _updateLastRead({
    int? surahId,
    int? ayah,
    int? page,
    required String mode,
  }) async {
    final db = await dbHelper.database;
    final activeSurah = await _resolveActiveSurahForEntry(
      mode: mode,
      surahId: surahId,
      page: page,
    );

    final now = DateTime.now().toIso8601String();

    await db.insert('last_read', {
      'surah_id': activeSurah ?? surahId,
      'ayah': ayah,
      'page': page,
      'mode': mode,
      'updated_at': now,
    });
  }

  // clear last_read when mode changes to ensure only ayah or page data are stored in last_read
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

  Future<double?> getSurahProgress({
    required int surahId,
    required int totalAyahs,
  }) async {
    final result = await _calculateSingleSurahProgress(surahId, totalAyahs);
    return result;
  }

  Future<double?> _calculateSingleSurahProgress(
    int surahId,
    int totalAyahs,
  ) async {
    final db = await dbHelper.database;

    final rows = await db.query(
      'last_read',
      where: 'surah_id = ?',
      whereArgs: [surahId],
    );

    if (rows.isEmpty) return 0.0;

    final Set<int> uniqueAyahs = {};

    // 🔥 Since mode is uniform, just read it once
    final mode = rows.first['mode'];

    // =========================
    // AYAH MODE
    // =========================
    if (mode == 'ayah') {
      for (final row in rows) {
        final ayah = row['ayah'] as int?;
        if (ayah != null) {
          uniqueAyahs.add(ayah);
        }
      }
    }
    // =========================
    // PAGE MODE
    // =========================
    else if (mode == 'page') {
      // Avoid duplicate page loads
      final Set<int> uniquePages = {};

      for (final row in rows) {
        final page = row['page'] as int?;
        if (page != null && page >= _minQuranPage && page <= _maxQuranPage) {
          uniquePages.add(page);
        }
      }

      for (final page in uniquePages) {
        final ayahs = await loadPageAyahs(page);

        for (final ayah in ayahs) {
          if (ayah.surah == surahId) {
            uniqueAyahs.add(ayah.ayah);
          }
        }
      }
    }

    // =========================
    // FINAL PROGRESS
    // =========================
    if (totalAyahs == 0) return 0.0;

    return (uniqueAyahs.length / totalAyahs).clamp(0.0, 1.0);
  }

  Future<int?> resolveActiveSurah({
    required String mode,
    int? surahId,
    int? page,
  }) async {
    return _resolveActiveSurahForEntry(
      mode: mode,
      surahId: surahId,
      page: page,
    );
  }

  Future<int?> _resolveActiveSurahForEntry({
    required String mode,
    int? surahId,
    int? page,
  }) async {
    // =========================
    // AYAH MODE
    // =========================
    if (mode == 'ayah') return surahId;

    // =========================
    // INVALID PAGE CASE
    // =========================
    if (mode != 'page' || page == null) return null;

    final surahsOnPage = getSurahNumbersFromPage(page);

    if (surahsOnPage.isEmpty) return null;

    // =========================
    // 🔥 NEW FIX: SINGLE SURAH PAGE
    // =========================
    if (surahsOnPage.length == 1) {
      return surahsOnPage.first;
    }

    // =========================
    // MULTIPLE SURAHS ON PAGE
    // =========================
    final pageAyahs = await loadPageAyahs(page);

    if (pageAyahs.isEmpty) {
      return surahsOnPage.first;
    }

    final firstAyah = pageAyahs.first;

    // If page starts with a new surah (ayah 1)
    if (firstAyah.ayah == 1 && surahsOnPage.contains(firstAyah.surah)) {
      return firstAyah.surah;
    }

    // Otherwise, assume continuation → second surah
    if (surahsOnPage.length >= 2) {
      return surahsOnPage[1];
    }

    return surahsOnPage.first;
  }

  // ========================= STATS =========================

  Future<int?> getSurahsCompleted(List<dynamic> surahs) async {
    int completedSurahs = 0;

    for (final surah in surahs) {
      final progress = await _calculateSurahsProgress(
        surahId: surah.number,
        totalAyahs: surah.totalAyahs,
      );

      if (progress! >= 1.0) {
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

    // =========================
    // 1. DIRECT AYAH TRACKING
    // =========================
    final ayahResult = await db.rawQuery(
      '''
    SELECT DISTINCT ayah
    FROM reading_sessions
    WHERE mode = 'ayah' AND surah_id = ?
    ''',
      [surahId],
    );

    for (final row in ayahResult) {
      final ayah = row['ayah'] as int?;
      if (ayah != null) {
        uniqueAyahs.add(ayah);
      }
    }

    // ayah tracking based on pages read
    final range = surahPageRanges[surahId];

    if (range != null) {
      final pageResult = await db.rawQuery(
        '''
      SELECT DISTINCT page
      FROM reading_sessions
      WHERE mode = 'page'
        AND page BETWEEN ? AND ?
      ''',
        [range.start, range.end],
      );

      for (final row in pageResult) {
        final page = row['page'] as int?;

        if (page != null && page >= _minQuranPage && page <= _maxQuranPage) {
          final ayahs = await loadPageAyahs(page);

          for (final ayah in ayahs) {
            // Only include ayahs of THIS surah
            if (ayah.surah == surahId) {
              uniqueAyahs.add(ayah.ayah);
            }
          }
        }
      }
    }

    if (totalAyahs == 0) return 0;

    final result = (uniqueAyahs.length / totalAyahs).clamp(0.0, 1.0);
    return result;
  }

  Future<double> getQuranProgress() async {
    final totalReadAyahs = await getTotalVersesRead();

    const totalAyahs = 6236;

    return (totalReadAyahs / totalAyahs).clamp(0.0, 1.0);
  }

  Future<int> getTotalVersesRead() async {
    final db = await dbHelper.database;

    // 1. Get ayahs read directly
    final ayahResult = await db.rawQuery('''
    SELECT DISTINCT surah_id, ayah
    FROM reading_sessions
    WHERE mode = 'ayah'
  ''');

    final Set<String> uniqueAyahs = {};

    for (final row in ayahResult) {
      final surah = row['surah_id'];
      final ayah = row['ayah'];
      if (surah != null && ayah != null) {
        uniqueAyahs.add('$surah-$ayah');
      }
    }

    // 2. Get pages read
    final pageResult = await db.rawQuery('''
    SELECT DISTINCT page
    FROM reading_sessions
    WHERE mode = 'page'
  ''');

    // 3. Convert pages → ayahs
    for (final row in pageResult) {
      final page = row['page'] as int?;

      if (page != null && page >= _minQuranPage && page <= _maxQuranPage) {
        final ayahs = await loadPageAyahs(page);

        for (final ayah in ayahs) {
          uniqueAyahs.add('${ayah.surah}-${ayah.ayah}');
        }
      }
    }

    // 4. Final count
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

    // Delete all rows from reading_sessions
    await db.delete('reading_sessions');

    // Also clear last_read so the UI doesn't try to resume a deleted session
    await db.delete('last_read');
  }
}
