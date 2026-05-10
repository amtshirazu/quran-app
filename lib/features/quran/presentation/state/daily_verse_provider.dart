import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/quran.dart' as quran_data;
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/state/translation_provider.dart';
import '../../domain/models/surah.dart';

// We keep this to store the "triple" result
class DailyVerse {
  final String arabicText;
  final String translation;
  final Surah? surah;
  final int ayahNumber;

  DailyVerse({
    required this.arabicText,
    required this.translation,
    required this.surah,
    required this.ayahNumber,
  });
}

final dailyVerseWithTranslationProvider = FutureProvider<DailyVerse>((
  ref,
) async {
  final surahs = ref.watch(surahListProvider).value;

  final today = DateTime.now();
  final seed = today.year * 10000 + today.month * 100 + today.day;
  final random = Random(seed);

  final surahNumber = random.nextInt(114) + 1;
  final totalAyahs = quran_data.getVerseCount(surahNumber);
  final ayahNumber = random.nextInt(totalAyahs) + 1;

  final arabicText = quran_data.getVerse(surahNumber, ayahNumber);

  final translationService = ref.read(translationServiceProvider);
  final translationText = await translationService.getTranslation(
    surahNumber,
    ayahNumber,
  );

  final currentSurah = surahs?.firstWhere((s) => s.number == surahNumber);

  return DailyVerse(
    arabicText: arabicText,
    translation: translationText,
    surah: currentSurah,
    ayahNumber: ayahNumber,
  );
});
