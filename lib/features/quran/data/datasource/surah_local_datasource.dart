import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SurahLocalDatasource {
  Future<List<dynamic>> loadSurahJson() async {
    final String response = await rootBundle.loadString(
      "assets/metadata/surah_metadata.json",
    );
    return compute(_parseSurahJson, response);
  }

  static List<dynamic> _parseSurahJson(String jsonString) {
    return jsonDecode(jsonString) as List<dynamic>;
  }
}
