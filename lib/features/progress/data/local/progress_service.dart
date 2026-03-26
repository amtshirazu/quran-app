import 'package:quran_app/features/progress/data/local/database_helper.dart';





class ProgressService {

  final dbHelper = DatabaseHelper.instance;

  Future<void> trackAyah(int surahId, int Ayah) async{
    final db = await dbHelper.database;

    final now = DateTime.now().toIso8601String();
    await db.insert('reading_session', {
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

  Future<void> trackPage(int page) async {
    final db = await dbHelper.database;

    final now = DateTime.now().toIso8601String();

    await db.insert('reading_sessions', {
      'mode': 'page',
      'surah_id': null,
      'ayah': null,
      'page': page,
      'timestamp': now,
    });

    await _updateLastRead(
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
      'page': null,
      'updated_at': now,
    });
  }


  Future<Map<String, dynamic>?> getLastRead() async {
    final db = await dbHelper.database;

    final result = await db.query('last_read', limit: 1);

    if(result.isEmpty) return null;
    return result.first;
  }

}