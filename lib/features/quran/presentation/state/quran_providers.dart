import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_app/features/audio/presentation/state/audio_service.dart';
import 'package:quran_app/features/quran/data/datasource/ayah_local_datasource.dart';
import 'package:quran_app/features/quran/data/datasource/surah_local_datasource.dart';
import 'package:quran_app/features/quran/data/repository/quran_metadata.dart';
import 'package:quran_app/features/quran/data/repository/quran_repository.dart';
import 'package:quran_app/features/quran/presentation/state/reading_mode.dart';
import '../../data/datasource/translation_local_datasource.dart';
import '../../data/repository/paged_repository.dart';
import '../../data/repository/translation_repository.dart';
import '../../domain/models/ayah.dart';
import '../../domain/models/surah.dart';
import '../../domain/models/translation.dart';

final surahRepositoryProvider =
Provider<SurahMetadataRepository>((ref) {
  return SurahMetadataRepository(
    surahs: SurahLocalDatasource(),
  );
});

final surahListProvider =
FutureProvider((ref) async {
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


final pagedRepositoryProvider =
Provider<PagedRepository>((ref) {
  return PagedRepository();
});


final pagedListProvider =
FutureProvider.family((ref,surahId) async {
  final repo = ref.watch(pagedRepositoryProvider);

  try {
    final allPages = await repo.loadPages();
    print("Loaded ${allPages.length} surahs");
    return allPages.where((p) => p.surahNumbers.contains(surahId)).toList();;
  } catch (e, st) {
    print("ERROR loading surahs: $e");
    print(st);
    rethrow;
  }
});

final ayahRepositoryProvider =
    Provider<QuranRepository>((ref) {
      return QuranRepository(datasource: QuranLocalDatasource());
    });

final ayahListProvider =
    FutureProvider.family<List<Ayah>, Map<String, dynamic>>((ref,params) async {
      final repo = ref.watch(ayahRepositoryProvider);
      final surahNumber = params["surahNumber"];
      final script = params["script"];

      try {
        final data = await repo.getSurahAyahs(surahNumber: surahNumber, script: script);
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
  return TranslationRepository(
    datasource: TranslationLocalDatasource(),
  );
});

// ---------------- Translation List Provider ----------------
final translationListProvider = FutureProvider.family<List<Translation>, Map<String, dynamic>>((ref, params) async {
  final repo = ref.watch(translationRepositoryProvider);
  final int surahNumber = params['surahNumber'];
  final String translationFile = params['translationFile'];

  try {
    final translations = await repo.getSurahTranslations(
      surahNumber: surahNumber,
      translationFile: translationFile,
    );
    return translations;
  } catch (e, st) {
    rethrow;
  }
});

final ayahParamsProvider = Provider<Map<String, dynamic>?>((ref) {
  final surah = ref.watch(selectedSurahProvider);

  if (surah == null) return null;

  return {
    "surahNumber": surah.number,
    "script": "uthmani",
  };
});

final translationParamsProvider =
Provider<Map<String, dynamic>?>((ref) {
  final surah = ref.watch(selectedSurahProvider);

  if (surah == null) return null;

  return {
    "surahNumber": surah.number,
    "translationFile": "saheeh",
  };
});

final readingModeProvider = StateProvider<ReadingMode>((ref) {
  return ReadingMode.translation;
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedSurahProvider = StateProvider<Surah?>((ref) => null);