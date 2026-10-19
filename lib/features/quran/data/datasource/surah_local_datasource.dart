import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:quran_app/features/quran/domain/models/surah.dart';

class SurahLocalDatasource {
  Future<List<Surah>> loadSurahs() async {
    final String jsonString = await rootBundle.loadString(
      "assets/metadata/surah_metadata.json",
      cache: false,
    );
    return await Isolate.run(() => _parseAndMapSurahs(jsonString));
  }

  static List<Surah> _parseAndMapSurahs(String jsonString) {
    final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded
        .map((e) => Surah.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<dynamic>> loadSurahJson() async {
    final String jsonString = await rootBundle.loadString(
      "assets/metadata/surah_metadata.json",
      cache: false,
    );
    return await Isolate.run(() => jsonDecode(jsonString) as List<dynamic>);
  }
}
