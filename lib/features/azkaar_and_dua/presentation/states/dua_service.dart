import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:quran_app/features/azkaar_and_dua/domain/model/quranic_dua.dart';
import 'package:sqflite/sqflite.dart';

class QuranicDuaDatabaseService {
  Database? _db;
  final String dbFileName = "quranic_duas.db";

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
        // Updated path to reflect project structure file tree
        final assetPath = 'assets/database/azkaar_and_dua/$dbFileName';

        await Directory(dirname(path)).create(recursive: true);

        // Copy from assets to device local storage
        ByteData data = await rootBundle.load(assetPath);
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        throw Exception("Error copying Quranic Duas database from assets: $e");
      }
    }

    return await openDatabase(path, readOnly: true);
  }

  // Fetch ALL Duas
  Future<List<QuranicDua>> getAllDuas() async {
    final db = await database;

    // Querying the 'duas' table shown in DB
    final List<Map<String, dynamic>> maps = await db.query('duas');

    return maps.map((map) => QuranicDua.fromMap(map)).toList();
  }

  Future<List<QuranicDua>> searchDuas(String query) async {
    final db = await database;
    final wildCardQuery = "%$query%";

    // Searches comprehensively across subject fields, literal translation arrays, or phonetics
    final List<Map<String, dynamic>> maps = await db.query(
      'duas',
      where:
          'subject LIKE ? OR translation LIKE ? OR transliteration LIKE ? OR arabic LIKE ?',
      whereArgs: [wildCardQuery, wildCardQuery, wildCardQuery, wildCardQuery],
    );

    return maps.map((map) => QuranicDua.fromMap(map)).toList();
  }
}
