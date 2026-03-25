import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import '../../domain/models/ayah.dart';
import '../../domain/models/surah.dart';
import '../../domain/models/translation.dart';
import '../state/quran_providers.dart';


class DailyVerse {
  final Ayah ayah;
  final Translation translation;
  final Surah? surah;

  DailyVerse({
    required this.ayah,
    required this.translation,
    required this.surah
  });
}

final dailyVerseWithTranslationProvider = FutureProvider<DailyVerse>((ref) async {
  final ayahRepo = ref.watch(ayahRepositoryProvider);
  final translationRepo = ref.watch(translationRepositoryProvider);
  final surah = ref.watch(surahListProvider).value;

  final today = DateTime.now();
  final seed = today.year * 10000 + today.month * 100 + today.day;
  final random = Random(seed);

  final surahNumber = random.nextInt(114) + 1;

  final ayahs = await ayahRepo.getSurahAyahs(surahNumber: surahNumber, script: "uthmani");
  if (ayahs.isEmpty) throw Exception("No ayahs in Surah $surahNumber");

  final ayahIndex = random.nextInt(ayahs.length);
  final ayah = ayahs[ayahIndex];

  final translations = await translationRepo.getSurahTranslations(
    surahNumber: surahNumber,
    translationFile: "saheeh",
  );


  final translation = translations.firstWhere(
        (t) => t.ayahNumber == ayah.ayahNumber,
    orElse: () => Translation(
      ayahNumber: ayah.ayahNumber,
      text: "Translation not found", surahNumber: surahNumber,
    ),
  );

  final currentSurah = surah?.firstWhere((s) => s.number == surahNumber);


  return DailyVerse(ayah: ayah, translation: translation, surah: currentSurah);
});