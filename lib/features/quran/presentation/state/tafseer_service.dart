import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TafseerDatabaseService {
  static final Map<String, Database> _dbCache = {};

  Future<Database> _getDatabase(String fileName) async {
    if (_dbCache.containsKey(fileName)) {
      return _dbCache[fileName]!;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    final exists = await databaseExists(path);

    if (!exists) {
      try {
        final assetPath = 'assets/database/tafseer/$fileName';

        await Directory(dirname(path)).create(recursive: true);

        // Copy database from assets
        ByteData data = await rootBundle.load(assetPath);
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        throw Exception("Error copying tafseer database $fileName from assets: $e");
      }
    }

    final db = await openDatabase(path, readOnly: true);
    _dbCache[fileName] = db;
    return db;
  }

  String _cleanHtmlText(String text) {
    var clean = text
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'</h[1-6]>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'</div\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .trim();

    clean = clean.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return clean;
  }

  Future<String> getTafseerFromDb({
    required String fileName,
    required int surah,
    required int verse,
  }) async {
    try {
      final db = await _getDatabase(fileName);
      final key = "$surah:$verse";

      // Inspect tables in SQLite database
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");

      for (final tableMap in tables) {
        final tableName = tableMap['name'] as String;
        if (tableName.startsWith('sqlite_')) continue;

        final columnsInfo = await db.rawQuery("PRAGMA table_info($tableName)");
        final columnNames = columnsInfo.map((c) => (c['name'] as String).toLowerCase()).toList();

        String? textCol;
        for (final c in ['text', 'content', 'tafsir', 'body']) {
          if (columnNames.contains(c)) {
            textCol = c;
            break;
          }
        }
        if (textCol == null) continue;

        List<Map<String, dynamic>> results = [];

        // Strategy 1: Check ayah_key or group_ayah_key
        if (columnNames.contains('ayah_key')) {
          results = await db.query(
            tableName,
            columns: [textCol],
            where: 'ayah_key = ?',
            whereArgs: [key],
          );
        }

        if (results.isEmpty && columnNames.contains('group_ayah_key')) {
          results = await db.query(
            tableName,
            columns: [textCol],
            where: 'group_ayah_key = ?',
            whereArgs: [key],
          );
        }

        // Strategy 2: Check ayah_keys contains key
        if (results.isEmpty && columnNames.contains('ayah_keys')) {
          results = await db.query(
            tableName,
            columns: [textCol],
            where: 'ayah_keys LIKE ? OR ayah_keys = ?',
            whereArgs: ['%$key%', key],
          );
        }

        // Strategy 3: Check sura / surah and ayah / verse columns
        if (results.isEmpty) {
          String? surahCol;
          for (final c in ['sura', 'surah', 'sura_id', 'surah_id', 'chapter']) {
            if (columnNames.contains(c)) {
              surahCol = c;
              break;
            }
          }

          String? verseCol;
          for (final c in ['ayah', 'verse', 'ayah_id', 'verse_id']) {
            if (columnNames.contains(c)) {
              verseCol = c;
              break;
            }
          }

          if (surahCol != null && verseCol != null) {
            results = await db.query(
              tableName,
              columns: [textCol],
              where: '$surahCol = ? AND $verseCol = ?',
              whereArgs: [surah, verse],
            );
          }
        }

        if (results.isNotEmpty) {
          final rawText = results.first[textCol] as String?;
          if (rawText != null && rawText.trim().isNotEmpty) {
            return _cleanHtmlText(rawText);
          }
        }
      }

      return "Tafseer text not available for this verse.";
    } catch (e) {
      return "Unable to load Tafseer for this verse.";
    }
  }
}
