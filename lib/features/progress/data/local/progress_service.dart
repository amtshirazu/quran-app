import 'package:quran_app/features/progress/data/local/database_helper.dart';
import 'package:quran_app/features/quran/data/repository/paged_repository.dart';
import '../../../quran/presentation/widgets/ayah_details_widget/paged/paged_surah_map.dart';

class ProgressService {
  final dbHelper = DatabaseHelper.instance;

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
    final db = await dbHelper.database;

    final now = DateTime.now().toIso8601String();
    final surahId = getSurahNumberFromPage(page);

    await db.insert('reading_sessions', {
      'mode': 'page',
      'surah_id': surahId,
      'ayah': null,
      'page': page,
      'timestamp': now,
    });

    await _updateLastRead(surahId: surahId, page: page, mode: 'page');

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

    await db.delete('last_read');

    final now = DateTime.now().toIso8601String();

    await db.insert('last_read', {
      'surah_id': surahId,
      'ayah': ayah,
      'page': page,
      'mode': mode,
      'updated_at': now,
    });
  }

  Future<Map<String, dynamic>?> getLastRead() async {
    final db = await dbHelper.database;

    final result = await db.query('last_read', limit: 1);

    if (result.isEmpty) return null;

    return result.first;
  }

  // ========================= CORE LOGIC =========================

  Future<double?> getSurahProgress({
    required int surahId,
    required int totalAyahs,
  }) async {
    final result = await _calculateProgress(surahId, totalAyahs);
    return result;
  }

  Future<double?> _calculateProgress(int surahId, int totalAyahs) async {
    final db = await dbHelper.database;

    // AYAH PROGRESS
    final ayahResult = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT ayah) as count
      FROM reading_sessions
      WHERE mode = 'ayah' AND surah_id = ?
    ''',
      [surahId],
    );

    final readAyahs = (ayahResult.first['count'] as int?) ?? 0;

    double ayahProgress = 0;
    if (totalAyahs > 0) {
      ayahProgress = readAyahs / totalAyahs;
    }

    // PAGE PROGRESS
    final startPage = surahStartPage[surahId] ?? 1;
    final nextStart = surahStartPage[surahId + 1] ?? 605;
    final endPage = nextStart - 1;

    final totalPages = endPage - startPage + 1;

    final pageResult = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT page) as count
      FROM reading_sessions
      WHERE mode = 'page'
        AND page BETWEEN ? AND ?
    ''',
      [startPage, endPage],
    );

    final pagesRead = (pageResult.first['count'] as int?) ?? 0;

    double pageProgress = 0;
    if (totalPages > 0) {
      pageProgress = pagesRead / totalPages;
    }

    // COMBINE
    return ayahProgress > pageProgress ? ayahProgress : pageProgress;
  }

  // ========================= STATS =========================

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

      if (page != null) {
        final ayahs = await loadPageAyahs(page);

        for (final ayah in ayahs) {
          uniqueAyahs.add('${ayah.surah}-${ayah.ayah}');
        }
      }
    }

    // 4. Final count
    return uniqueAyahs.length;
  }

  Future<int?> getSurahsCompleted(List<dynamic> surahs) async {
    int completedSurahs = 0;

    for (final surah in surahs) {
      final progress = await getSurahProgress(
        surahId: surah.number,
        totalAyahs: surah.totalAyahs,
      );

      if (progress! >= 1.0) {
        completedSurahs++;
      }
    }

    return completedSurahs;
  }

  Future<double> getQuranProgress() async {
    final totalReadAyahs = await getTotalVersesRead();

    const totalAyahs = 6236;

    return (totalReadAyahs / totalAyahs).clamp(0.0, 1.0);
  }
}
