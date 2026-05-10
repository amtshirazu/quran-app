import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TranslationDatabaseService {
  Database? _db;
  final String dbFileName;

  TranslationDatabaseService({required this.dbFileName});

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
        final assetPath = 'assets/database/translations/$dbFileName';

        await Directory(dirname(path)).create(recursive: true);

        // Copy from assets
        ByteData data = await rootBundle.load(assetPath);
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        throw Exception("Error copying database from assets: $e");
      }
    }

    return await openDatabase(path, readOnly: true);
  }

  Future<String> getTranslation(int surah, int verse) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'translation',
      columns: ['text'],
      where: 'sura = ? AND ayah = ?',
      whereArgs: [surah, verse],
    );

    if (maps.isNotEmpty) {
      return maps.first['text'] as String;
    }
    return "Translation not found";
  }
}
