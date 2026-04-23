import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/models/paged.dart';

Future<List<PagedAyah>> loadPageAyahs(int pageNumber) async {
  final data = await rootBundle.loadString(
    'assets/quran/hafs/${pageNumber.toString().padLeft(3, '0')}.json',
  );

  final List<dynamic> jsonList = json.decode(data);
  final ayahs = jsonList.map((e) => PagedAyah.fromJson(e)).toList();
  return ayahs;
}
