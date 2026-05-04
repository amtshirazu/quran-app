import 'package:quran_app/core/database/database_helper.dart';

class ReflectionService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> addOrUpdateReflection({
    required int surahId,
    required int ayahNumber,
    required String content,
  }) async {
    final db = await _databaseHelper.database;
    final createdAt = DateTime.now().toIso8601String();

    final existing = await db.query(
      'reflections',
      where: 'surah_id = ? AND ayah_number = ?',
      whereArgs: [surahId, ayahNumber],
    );

    if (existing.isNotEmpty) {
      await db.update(
        'reflections',
        {'content': content, 'created_at': createdAt},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      await db.insert('reflections', {
        'surah_id': surahId,
        'ayah_number': ayahNumber,
        'content': content,
        'created_at': createdAt,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getAllReflections() async {
    final db = await _databaseHelper.database;
    return await db.query('reflections', orderBy: 'created_at DESC');
  }

  Future<void> deleteReflection(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('reflections', where: 'id = ?', whereArgs: [id]);
  }
}
