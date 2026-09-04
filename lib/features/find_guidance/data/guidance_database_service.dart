import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../domain/model/guidance_verse.dart';

class GuidanceDatabaseService {
  Database? _db;
  final String dbFileName = "guidance_verses.db";

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
        final assetPath = 'assets/database/find_guidance/$dbFileName';

        await Directory(dirname(path)).create(recursive: true);

        // Copy from assets to local application storage
        ByteData data = await rootBundle.load(assetPath);
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        throw Exception("Error copying Find Guidance database from assets: $e");
      }
    }

    return await openDatabase(path, readOnly: true);
  }

  /// Get map of emotion name -> count of verses
  Future<Map<String, int>> getEmotionVerseCounts() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT emotion, COUNT(*) as count FROM verses GROUP BY emotion',
    );

    final Map<String, int> counts = {};
    for (var row in result) {
      counts[row['emotion'] as String] = row['count'] as int;
    }
    return counts;
  }

  /// Fetch verses for a specific emotion
  Future<List<GuidanceVerse>> getVersesByEmotion(String emotion) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'verses',
      where: 'emotion = ?',
      whereArgs: [emotion],
    );

    return maps.map((map) => GuidanceVerse.fromMap(map)).toList();
  }
}
