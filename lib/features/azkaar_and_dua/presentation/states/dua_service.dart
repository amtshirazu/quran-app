import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:quran_app/features/azkaar_and_dua/domain/model/quranic_dua.dart';

enum DuaCategory {
  quranic, // Quranic Duas
  witr,    // Witr & Qunoot Duas
}

class DuaDatabaseService {
  Database? _quranicDb;
  Database? _witrDb;

  final String quranicDbFileName = "quranic_duas.db";
  final String witrDbFileName = "witr_duas.db";

  Future<Database> _getDatabase(DuaCategory category) async {
    if (category == DuaCategory.quranic) {
      if (_quranicDb != null) return _quranicDb!;
      _quranicDb = await _initDb(quranicDbFileName);
      return _quranicDb!;
    } else {
      if (_witrDb != null) return _witrDb!;
      _witrDb = await _initDb(witrDbFileName);
      return _witrDb!;
    }
  }

  Future<Database> _initDb(String dbFileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbFileName);

    final exists = await databaseExists(path);

    if (!exists) {
      try {
        final assetPath = 'assets/database/azkaar_and_dua/$dbFileName';

        await Directory(dirname(path)).create(recursive: true);

        ByteData data = await rootBundle.load(assetPath);
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        throw Exception("Error copying database $dbFileName from assets: $e");
      }
    }

    return await openDatabase(path, readOnly: true);
  }

  /// Fetch all duas for selected category
  Future<List<QuranicDua>> getDuasByCategory(DuaCategory category) async {
    final db = await _getDatabase(category);
    final List<Map<String, dynamic>> maps = await db.query('duas');

    final categoryType = category == DuaCategory.quranic ? 'quranic' : 'witr';
    return maps.map((map) => QuranicDua.fromMap(map, categoryType: categoryType)).toList();
  }

  /// Search duas within selected category
  Future<List<QuranicDua>> searchDuasByCategory(DuaCategory category, String query) async {
    final db = await _getDatabase(category);
    final wildCardQuery = "%$query%";
    final categoryType = category == DuaCategory.quranic ? 'quranic' : 'witr';

    List<Map<String, dynamic>> maps;

    if (category == DuaCategory.quranic) {
      maps = await db.query(
        'duas',
        where: 'subject LIKE ? OR translation LIKE ? OR transliteration LIKE ? OR arabic LIKE ?',
        whereArgs: [wildCardQuery, wildCardQuery, wildCardQuery, wildCardQuery],
      );
    } else {
      maps = await db.query(
        'duas',
        where: 'source LIKE ? OR translation LIKE ? OR transliteration LIKE ? OR arabic LIKE ?',
        whereArgs: [wildCardQuery, wildCardQuery, wildCardQuery, wildCardQuery],
      );
    }

    return maps.map((map) => QuranicDua.fromMap(map, categoryType: categoryType)).toList();
  }
}
