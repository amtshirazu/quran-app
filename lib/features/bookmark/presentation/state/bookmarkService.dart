import 'package:quran_app/core/database/database_helper.dart';
import 'package:quran_app/features/bookmark/domain/model/bookmark.dart';

class BookmarkService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  /// Add a new bookmark
  Future<int> addBookmark({
    required int surahId,
    required int ayahNumber,
    int? page,
    String? note,
  }) async {
    final db = await _databaseHelper.database;
    final createdAt = DateTime.now().toIso8601String();

    return await db.insert('bookmarks', {
      'surah_id': surahId,
      'ayah_number': ayahNumber,
      'page': page,
      'note': note,
      'created_at': createdAt,
    });
  }

  /// Get all bookmarks
  Future<List<Bookmark>> getAllBookmarks() async {
    final db = await _databaseHelper.database;
    final result = await db.query('bookmarks', orderBy: 'created_at DESC');

    return result.map((json) => Bookmark.fromJson(json)).toList();
  }

  /// Get bookmarks for a specific surah
  Future<List<Bookmark>> getBookmarksBySurah(int surahId) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'bookmarks',
      where: 'surah_id = ?',
      whereArgs: [surahId],
      orderBy: 'ayah_number ASC',
    );

    return result.map((json) => Bookmark.fromJson(json)).toList();
  }

  /// Get a specific bookmark
  Future<Bookmark?> getBookmark(int id) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'bookmarks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;
    return Bookmark.fromJson(result.first);
  }

  /// Update a bookmark
  Future<int> updateBookmark({
    required int id,
    int? surahId,
    int? ayahNumber,
    int? page,
    String? note,
  }) async {
    final db = await _databaseHelper.database;
    final updateData = <String, dynamic>{};

    if (surahId != null) updateData['surah_id'] = surahId;
    if (ayahNumber != null) updateData['ayah_number'] = ayahNumber;
    if (page != null) updateData['page'] = page;
    if (note != null) updateData['note'] = note;

    if (updateData.isEmpty) return 0;

    return await db.update(
      'bookmarks',
      updateData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a bookmark
  Future<int> deleteBookmark(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
  }

  /// Check if a specific ayah is bookmarked
  Future<bool> isBookmarked(int surahId, int ayahNumber) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'bookmarks',
      where: 'surah_id = ? AND ayah_number = ?',
      whereArgs: [surahId, ayahNumber],
    );

    return result.isNotEmpty;
  }

  /// Delete all bookmarks
  Future<int> deleteAllBookmarks() async {
    final db = await _databaseHelper.database;
    return await db.delete('bookmarks');
  }
}
