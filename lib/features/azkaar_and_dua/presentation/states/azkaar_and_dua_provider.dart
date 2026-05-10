import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';

/// 1. Repository Provider
final muslimRepoProvider = Provider((ref) => MuslimRepository());

// 4. Chapters Provider (Families allow passing the category ID)
final chaptersProvider = FutureProvider.family<List<AzkarChapter>, int>((
  ref,
  categoryId,
) async {
  final repo = ref.watch(muslimRepoProvider);
  return await repo.getAzkarChapters(
    language: Language.en,
    categoryId: categoryId,
  );
});

// 2. Fetch the total count for a SPECIFIC category
final categoryItemCountProvider = FutureProvider.family<int, int>((
  ref,
  categoryId,
) async {
  final repo = ref.watch(muslimRepoProvider);
  int count = 0;

  // Get all chapters for this specific category
  final chapters = await repo.getAzkarChapters(
    language: Language.en,
    categoryId: categoryId,
  );

  // Sum up all items in those chapters
  for (var chapter in chapters) {
    final items = await repo.getAzkarItems(
      language: Language.en,
      chapterId: chapter.id,
    );
    count += items.length;
  }
  return count;
});

// 3. Categories Provider
final categoriesProvider = FutureProvider<List<AzkarCategory>>((ref) async {
  final repo = ref.watch(muslimRepoProvider);
  return await repo.getAzkarCategories(language: Language.en);
});
