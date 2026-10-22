import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:quran_app/features/audio/data/reciters_list.dart';

Future<void> main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final dbPath = 'assets/database/audio_timestamps.db';
  final file = File(dbPath);
  if (file.existsSync()) file.deleteSync();

  await Directory(file.parent.path).create(recursive: true);

  final db = await openDatabase(
    dbPath,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE ayah_timestamps (
          reciter_id TEXT NOT NULL,
          reciter_api_id INTEGER NOT NULL,
          surah_number INTEGER NOT NULL,
          ayah_number INTEGER NOT NULL,
          verse_key TEXT NOT NULL,
          timestamp_from INTEGER NOT NULL,
          timestamp_to INTEGER NOT NULL,
          PRIMARY KEY (reciter_id, surah_number, ayah_number)
        )
      ''');
      await db.execute(
        'CREATE INDEX idx_reciter_surah ON ayah_timestamps (reciter_id, surah_number)',
      );
    },
  );

  for (final reciter in reciters) {
    final reciterId = reciter.id;
    final readId = reciter.mp3QuranReadId;

    for (int surah = 1; surah <= 114; surah++) {
      final url = Uri.parse(
        'https://www.mp3quran.net/api/v3/ayat_timing?surah=$surah&read=$readId',
      );

      try {
        final res = await http.get(url);
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final timestamps = data as List<dynamic>? ?? [];

          final batch = db.batch();
          for (final item in timestamps) {
            final ayahNumber = item['ayah'] as int;
            final from = item['start_time'] as int;
            final to = item['end_time'] as int;

            batch.insert('ayah_timestamps', {
              'reciter_id': reciterId,
              'reciter_api_id': readId,
              'surah_number': surah,
              'ayah_number': ayahNumber,
              'verse_key': '$surah:$ayahNumber',
              'timestamp_from': from,
              'timestamp_to': to,
            });
          }
          await batch.commit(noResult: true);
        }
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  await db.close();
}
