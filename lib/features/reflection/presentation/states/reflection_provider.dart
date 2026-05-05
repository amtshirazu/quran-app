import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/reflection/domain/models/reflection_model.dart';
import 'package:quran_app/features/reflection/presentation/states/reflection_service.dart';

final reflectionServiceProvider = Provider((ref) => ReflectionService());

// Root data provider
final reflectionsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final service = ref.watch(reflectionServiceProvider);
  return await service.getAllReflections();
});

// UI-Ready provider (Watches root for automatic updates)
final reflectionsUIProvider = FutureProvider<List<ReflectionUIModel>>((
  ref,
) async {
  final rawData = await ref.watch(reflectionsProvider.future);
  final surahList = await ref.watch(surahListProvider.future);

  List<ReflectionUIModel> result = [];

  for (final item in rawData) {
    final surah = surahList.firstWhere((s) => s.number == item['surah_id']);

    result.add(
      ReflectionUIModel(
        id: item['id'],
        surah: surah,
        ayahNumber: item['ayah_number'],
        content: item['content'],
        date: DateTime.parse(item['created_at']),
      ),
    );
  }
  return result;
});

// Stats Provider for the Purple Card in your image
final reflectionStatsProvider = Provider((ref) {
  final reflectionsAsync = ref.watch(reflectionsProvider);

  return reflectionsAsync.maybeWhen(
    data: (list) {
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));

      final thisWeekCount = list.where((item) {
        final date = DateTime.parse(item['created_at']);
        return date.isAfter(oneWeekAgo);
      }).length;

      final uniqueSurahs = list.map((item) => item['surah_id']).toSet().length;

      return {
        'total': list.length,
        'thisWeek': thisWeekCount,
        'surahs': uniqueSurahs,
      };
    },
    orElse: () => {'total': 0, 'thisWeek': 0, 'surahs': 0},
  );
});

final reflectionSearchQueryProvider = StateProvider((ref) => "");

final filteredReflectionsProvider = Provider((ref) {
  final query = ref.watch(reflectionSearchQueryProvider).toLowerCase();
  final list = ref.watch(reflectionsUIProvider).value ?? [];

  if (query.isEmpty) return list;

  return list.where((item) {
    return item.content.toLowerCase().contains(query) ||
        item.surah.nameEnglish.toLowerCase().contains(query) ||
        item.ayahNumber.toString().contains(query);
  }).toList();
});
