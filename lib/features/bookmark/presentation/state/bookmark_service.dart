import 'package:quran_app/core/database/database_helper.dart';
import 'package:quran_app/features/bookmark/domain/model/bookmark.dart';

class BookmarkType {
  static const verse = 'verse';
  static const page = 'page';
}

class BookmarkService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  /// Add a new bookmark
  Future<int> addBookmark({
    int? surahId,
    int? ayahNumber,
    int? page,
    String? note,
    required String type, // 'verse' or 'page'
  }) async {
    final db = await _databaseHelper.database;
    final createdAt = DateTime.now().toIso8601String();

    return await db.insert('bookmarks', {
      'surah_id': surahId,
      'ayah_number': ayahNumber,
      'page': page,
      'note': note,
      'type': type,
      'created_at': createdAt,
    });
  }

  /// Get all bookmarks
  Future<List<Bookmark>> getAllBookmarks() async {
    final db = await _databaseHelper.database;
    final result = await db.query('bookmarks', orderBy: 'created_at DESC');

    return result.map((json) => Bookmark.fromJson(json)).toList();
  }

  // 1. Get ALL bookmarks that are for specific Ayahs
  Future<List<Bookmark>> getVerseBookmarks() async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'bookmarks',
      where: 'type = ?',
      whereArgs: [BookmarkType.verse],
      orderBy: 'created_at DESC',
    );

    return result.map((json) => Bookmark.fromJson(json)).toList();
  }

  // 2. Get ALL bookmarks that are for Pages
  Future<List<Bookmark>> getPageBookmarks() async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'bookmarks',
      where: 'type = ?',
      whereArgs: [BookmarkType.page],
      orderBy: 'created_at DESC',
    );

    return result.map((json) => Bookmark.fromJson(json)).toList();
  }

  /// Delete a bookmark
  Future<int> deleteBookmark(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete ONLY verse bookmarks (where ayah_number is not null)
  Future<int> deleteAllVerseBookmarks() async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'bookmarks',
      where: 'type = ?',
      whereArgs: [BookmarkType.verse],
    );
  }

  /// Delete ONLY page bookmarks (where ayah_number is null)
  Future<int> deleteAllPageBookmarks() async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'bookmarks',
      where: 'type = ?',
      whereArgs: [BookmarkType.page],
    );
  }

  /// Delete all bookmarks
  Future<int> deleteAllBookmarks() async {
    final db = await _databaseHelper.database;
    return await db.delete('bookmarks');
  }

  Future<void> addOrUpdateVerseBookmark({
    required int surahId,
    required int ayahNumber,
    required String note,
  }) async {
    final db = await _databaseHelper.database;

    final existing = await db.query(
      'bookmarks',
      where: 'type = ? AND surah_id = ? AND ayah_number = ?',
      whereArgs: [BookmarkType.verse, surahId, ayahNumber],
    );

    if (existing.isNotEmpty) {
      // UPDATE bookmark
      await db.update(
        'bookmarks',
        {'note': note, 'created_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      // INSERT
      await db.insert('bookmarks', {
        'surah_id': surahId,
        'ayah_number': ayahNumber,
        'page': null,
        'note': note,
        'type': BookmarkType.verse,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> addOrUpdatePageBookmark({
    required int page,
    required String note,
    required int surahId,
  }) async {
    final db = await _databaseHelper.database;

    final existing = await db.query(
      'bookmarks',
      where: 'type = ? AND page = ?',
      whereArgs: [BookmarkType.page, page],
    );

    if (existing.isNotEmpty) {
      // UPDATE bookmark
      await db.update(
        'bookmarks',
        {'note': note, 'created_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      // INSERT
      await db.insert('bookmarks', {
        'surah_id': surahId,
        'ayah_number': null,
        'page': page,
        'note': note,
        'type': BookmarkType.page,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }
}
