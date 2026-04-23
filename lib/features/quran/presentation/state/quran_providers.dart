import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quran_app/features/audio/domain/models/Reciters.dart';
import 'package:quran_app/features/quran/data/datasource/ayah_local_datasource.dart';
import 'package:quran_app/features/quran/data/datasource/surah_local_datasource.dart';
import 'package:quran_app/features/quran/data/repository/quran_metadata.dart';
import 'package:quran_app/features/quran/data/repository/quran_repository.dart';
import 'package:quran_app/features/quran/presentation/state/reading_mode.dart';
import '../../data/datasource/translation_local_datasource.dart';
import '../../data/repository/paged_repository.dart';
import '../../data/repository/translation_repository.dart';
import '../../domain/models/ayah.dart';
import '../../domain/models/paged.dart';
import '../../domain/models/surah.dart';
import '../../domain/models/translation.dart';

final surahRepositoryProvider = Provider<SurahMetadataRepository>((ref) {
  return SurahMetadataRepository(surahs: SurahLocalDatasource());
});

final surahListProvider = FutureProvider((ref) async {
  final repo = ref.watch(surahRepositoryProvider);

  try {
    final data = await repo.getSurahMetadata();
    print("Loaded ${data.length} surahs");
    return data;
  } catch (e, st) {
    print("ERROR loading surahs: $e");
    print(st);
    rethrow;
  }
});

final pageAyahsProvider = FutureProvider.family<List<PagedAyah>, int>((
  ref,
  pageNumber,
) async {
  return loadPageAyahs(pageNumber);
});

final ayahRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository(datasource: QuranLocalDatasource());
});

final ayahListProvider =
    FutureProvider.family<List<Ayah>, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final repo = ref.watch(ayahRepositoryProvider);
      final surahNumber = params["surahNumber"];
      final script = params["script"];

      try {
        final data = await repo.getSurahAyahs(
          surahNumber: surahNumber,
          script: script,
        );
        print("Loaded ${data.length} surahs");
        return data;
      } catch (e, st) {
        print("ERROR loading surahs: $e");
        print(st);
        rethrow;
      }
    });

// ---------------- Translation Repository ----------------
final translationRepositoryProvider = Provider<TranslationRepository>((ref) {
  return TranslationRepository(datasource: TranslationLocalDatasource());
});

// ---------------- Translation List Provider ----------------
final translationListProvider =
    FutureProvider.family<List<Translation>, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final repo = ref.watch(translationRepositoryProvider);
      final int surahNumber = params['surahNumber'];
      final String translationFile = params['translationFile'];

      try {
        final translations = await repo.getSurahTranslations(
          surahNumber: surahNumber,
          translationFile: translationFile,
        );
        return translations;
      } catch (e) {
        rethrow;
      }
    });

final ayahParamsProvider = Provider<Map<String, dynamic>?>((ref) {
  final surah = ref.watch(selectedSurahProvider);

  if (surah == null) return null;

  return {"surahNumber": surah.number, "script": "uthmani"};
});

final translationParamsProvider = Provider<Map<String, dynamic>?>((ref) {
  final surah = ref.watch(selectedSurahProvider);

  if (surah == null) return null;

  return {"surahNumber": surah.number, "translationFile": "saheeh"};
});

final readingModeProvider = StateProvider<ReadingMode>((ref) {
  return ReadingMode.translation;
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedSurahProvider = StateProvider<Surah?>((ref) => null);
final defaultReciterProvider = Provider<Reciter?>(
  (ref) => Reciter(
    id: "abu_bakr_shaatree",
    name: "Abu Bakr Ash-Shaatree",
    arabicName: "أبو بكر الشاطري",
    image: "assets/reciters/shatri.jpg",
    country: "Saudi Arabia",
    style: "Hafs - Murattal",
    totalSurahs: 114,
    audioFolder: "Abu_Bakr_Ash-Shaatree_128kbps",
    serverUrl: "https://server11.mp3quran.net/shatri",
  ),
);

final currentPlayingAyahProvider = StateProvider<AyahIdentifier?>(
  (ref) => null,
);

class AyahIdentifier {
  final int surah;
  final int ayah;
  final int page;
  AyahIdentifier({required this.surah, required this.ayah, required this.page});
}

final currentPlayingPageProvider = Provider<int?>((ref) {
  final playing = ref.watch(currentPlayingAyahProvider);
  return playing?.page;
});
