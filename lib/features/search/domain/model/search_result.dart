import 'package:quran_app/features/azkaar_and_dua/domain/model/quranic_dua.dart';
import 'package:quran_app/features/quran/domain/models/surah.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';

class AyahSearchResult {
  final int surahNum;
  final int ayahNum;
  final String surahName;
  final String arabicText;
  final String translationText;

  AyahSearchResult({
    required this.surahNum,
    required this.ayahNum,
    required this.surahName,
    required this.arabicText,
    required this.translationText,
  });
}

class AzkarSearchResult {
  final AzkarCategory category;
  final AzkarChapter chapter;
  final AzkarItem? item;

  AzkarSearchResult({
    required this.category,
    required this.chapter,
    this.item,
  });
}

class UnifiedSearchResults {
  final String query;
  final List<AyahSearchResult> ayahs;
  final List<Surah> surahs;
  final List<AzkarSearchResult> azkaar;
  final List<QuranicDua> duas;

  UnifiedSearchResults({
    required this.query,
    required this.ayahs,
    required this.surahs,
    required this.azkaar,
    required this.duas,
  });

  int get totalCount =>
      ayahs.length + surahs.length + azkaar.length + duas.length;
}
