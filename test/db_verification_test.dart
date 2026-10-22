import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:quran_app/features/audio/data/reciters_list.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Verify audio_timestamps.db schema and reciters', () async {
    final dbFile = File('assets/database/audio_timestamps.db');
    expect(
      dbFile.existsSync(),
      isTrue,
      reason: 'DB file must exist at ${dbFile.absolute.path}',
    );

    final db = await openDatabase(dbFile.absolute.path, readOnly: true);

    // Check tables
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='ayah_timestamps'",
    );
    expect(
      tables.isNotEmpty,
      isTrue,
      reason: 'ayah_timestamps table must exist',
    );

    // Check table columns
    final tableInfo = await db.rawQuery("PRAGMA table_info(ayah_timestamps)");
    print("Table columns: ${tableInfo.map((c) => c['name']).toList()}");

    // Check distinct reciter_ids in DB
    final reciterRows = await db.rawQuery(
      "SELECT DISTINCT reciter_id, reciter_api_id FROM ayah_timestamps",
    );
    print("Distinct reciters in DB: $reciterRows");

    // Compare with reciters in reciters_list.dart
    for (final reciter in reciters) {
      final rows = await db.query(
        'ayah_timestamps',
        where: 'reciter_id = ?',
        whereArgs: [reciter.id],
        limit: 5,
      );
      print(
        "Reciter '${reciter.id}' (mp3QuranReadId: ${reciter.mp3QuranReadId}) rows count in sample: ${rows.length}",
      );
      if (rows.isNotEmpty) {
        print("  Sample row: ${rows.first}");
        expect(
          rows.first['reciter_api_id'],
          equals(reciter.mp3QuranReadId),
          reason:
              'reciter_api_id in DB must match mp3QuranReadId for ${reciter.id}',
        );
      } else {
        fail(
          "No rows found for reciter_id '${reciter.id}' in audio_timestamps.db",
        );
      }
    }

    await db.close();
  });
}
