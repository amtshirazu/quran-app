import 'dart:convert';
import 'package:flutter/services.dart';

class SurahLocalDatasource {
  Future<List<dynamic>> loadSurahJson() async {
    final String response = await rootBundle.loadString(
      "assets/metadata/surah_metadata.json",
    );
    return jsonDecode(response);
  }
}
