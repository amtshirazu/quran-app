import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import 'package:quran_app/features/settings/presentation/state/display_settings_provider.dart';

/// Repository Provider
final muslimRepoProvider = Provider((ref) => MuslimRepository());

Language _getMuslimDataLanguage(String appLang) {
  switch (appLang) {
    case 'ar':
      return Language.ar;
    default:
      return Language.en;
  }
}

// Chapters Provider
final chaptersProvider = FutureProvider.family<List<AzkarChapter>, int>((
  ref,
  categoryId,
) async {
  final repo = ref.watch(muslimRepoProvider);
  final langCode = ref.watch(appLanguageProvider);
  final lang = _getMuslimDataLanguage(langCode);

  return await repo.getAzkarChapters(
    language: lang,
    categoryId: categoryId,
  );
});

// Items Provider
final itemsProvider = FutureProvider.family<List<AzkarItem>, int>((
  ref,
  chapterId,
) async {
  final repo = ref.watch(muslimRepoProvider);
  final langCode = ref.watch(appLanguageProvider);
  final lang = _getMuslimDataLanguage(langCode);

  return await repo.getAzkarItems(language: lang, chapterId: chapterId);
});

// Fetch the total count for a SPECIFIC category
final categoryItemCountProvider = FutureProvider.family<int, int>((
  ref,
  categoryId,
) async {
  final repo = ref.watch(muslimRepoProvider);
  final langCode = ref.watch(appLanguageProvider);
  final lang = _getMuslimDataLanguage(langCode);
  int count = 0;

  final chapters = await repo.getAzkarChapters(
    language: lang,
    categoryId: categoryId,
  );

  for (var chapter in chapters) {
    final items = await repo.getAzkarItems(
      language: lang,
      chapterId: chapter.id,
    );
    count += items.length;
  }
  return count;
});

final categoriesProvider = FutureProvider<List<AzkarCategory>>((ref) async {
  final repo = ref.watch(muslimRepoProvider);
  final langCode = ref.watch(appLanguageProvider);
  final lang = _getMuslimDataLanguage(langCode);

  return await repo.getAzkarCategories(language: lang);
});
