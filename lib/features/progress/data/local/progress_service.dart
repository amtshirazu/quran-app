import 'package:quran_app/features/progress/data/local/database_helper.dart';

import '../../../quran/presentation/widgets/ayah_details_widget/paged/paged_surah_map.dart';





class ProgressService {

  final dbHelper = DatabaseHelper.instance;

  Future<void> trackAyah(int surahId, int Ayah) async{
    final db = await dbHelper.database;

    final now = DateTime.now().toIso8601String();
    await db.insert('reading_sessions', {
      'mode': 'ayah',
      'surah_id': surahId,
      'ayah': Ayah,
      'page':null,
      'timestamp': now,
    });

    await _updateLastRead(
      surahId: surahId,
      ayah: Ayah,
      mode: 'ayah',
    );
  }


  // features/progress/data/progress_service.dart

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

    await _updateLastRead(
      surahId: surahId,
      page: page,
      mode: 'page',
    );
  }

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
      'updated_at': now,
      'mode': mode,
    });
  }


  Future<Map<String, dynamic>?> getLastRead() async {
    final db = await dbHelper.database;

    final result = await db.query('last_read', limit: 1);

    if(result.isEmpty) return null;
    return result.first;
  }


  Future<double> getCurrentSurahProgressFromLastRead({
    required int totalAyahs,
  }) async {

    final db = dbHelper.database;

    final lastRead = await getLastRead();

    if(lastRead == null) return 0.0;

    final mode  = lastRead['mode'] as String?;
    final surahId = lastRead['surah_id'] as int?;
    final ayah = lastRead['ayah'] as int?;
    final page = lastRead['page'] as int?;

    if(mode == null || surahId == null) return 0.0;

    if(mode == 'ayah') {
      if(ayah == null || totalAyahs == 0) return 0.0;

      final progress = ayah / totalAyahs;
      return progress.clamp(0.0, 1.0);
    }

    // features/progress/data/progress_service.dart

    if (mode == 'page') {
      if (page == null) return 0.0;

      final int startPage = surahStartPage[surahId] ?? 1;

      final int nextSurahStart = surahStartPage[surahId + 1] ?? 605;
      final int endPage = nextSurahStart - 1;

      final totalPagesInSurah = endPage - startPage + 1;
      final pagesRead = page - startPage + 1;

      if (totalPagesInSurah <= 0) return 0.0;


      final progress = pagesRead / totalPagesInSurah;
      return progress.clamp(0.0, 1.0);
    }

    return 0.0;
  }


  Future<double> getQuranProgress(
      int surahId,
      int totalAyahs,
      ) async {
    final db = await dbHelper.database;

    // 🟩 AYAH PROGRESS
    final ayahResult = await db.rawQuery('''
    SELECT COUNT(DISTINCT ayah) as count
    FROM reading_sessions
    WHERE mode = 'ayah' AND surah_id = ?
  ''', [surahId]);

    final readAyahs = (ayahResult.first['count'] as int?) ?? 0;

    double ayahProgress = 0;
    if (totalAyahs > 0) {
      ayahProgress = readAyahs / totalAyahs;
    }

    final startPage = surahStartPage[surahId] ?? 1;


    final nextSurahStart = surahStartPage[surahId + 1];
    final endPage = nextSurahStart != null
        ? nextSurahStart - 1
        : 604;

    final totalPages = endPage - startPage + 1;


    final pageResult = await db.rawQuery('''
    SELECT MAX(page) as maxPage
    FROM reading_sessions
    WHERE mode = 'page'
      AND page BETWEEN ? AND ?
  ''', [startPage, endPage]);

    final maxPage = pageResult.first['maxPage'] as int?;

    double pageProgress = 0;

    if (maxPage != null && totalPages > 0) {
      final progressPages = maxPage - startPage + 1;

      if (progressPages > 0) {
        pageProgress = progressPages / totalPages;
      }
    }


    final progress = ayahProgress > pageProgress
        ? ayahProgress
        : pageProgress;

    return progress.clamp(0.0, 1.0);
  }




}