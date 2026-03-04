import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/models/paged.dart';



class PagedRepository {

  Future<List<PageGlyph>> loadPages() async {
    final String jsonString = await rootBundle.loadString('lib/assets/quran/scripts/mushaf_pages.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((e) => PageGlyph.fromJson(e)).toList();
  }

}