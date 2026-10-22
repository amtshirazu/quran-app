import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/states/azkaar_provider.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/states/dua_provider.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/state/translation_provider.dart';
import '../../data/search_service.dart';
import '../../domain/model/recent_search.dart';
import '../../domain/model/search_result.dart';

enum SearchTab { all, ayah, surah, azkaar, dua }

/// Service Provider injecting cross-domain dependencies into SearchService
final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService(
    translationService: ref.watch(translationServiceProvider),
    duaService: ref.watch(duaServiceProvider),
    muslimRepo: ref.watch(muslimRepoProvider),
  );
});

/// Currently selected search filter tab
final searchTabFilterProvider = StateProvider<SearchTab>((ref) {
  return SearchTab.all;
});

/// Fetches up to 8 recent searches directly from SearchService
final recentSearchesProvider = FutureProvider<List<RecentSearch>>((ref) async {
  final service = ref.watch(searchServiceProvider);
  return await service.getRecentSearches(limit: 8);
});

/// State for Recent Searches section expansion ("View All" vs "Show Less")
final recentSearchesExpandedProvider = StateProvider<bool>((ref) => false);

/// State for Popular Searches section expansion ("View All" vs "Show Less")
final popularSearchesExpandedProvider = StateProvider<bool>((ref) => false);

/// Current search query string state
final activeSearchQueryProvider = StateProvider<String>((ref) => '');

/// Daily Popular Searches Provider delegating calculation to SearchService
final popularSearchesProvider = Provider<List<String>>((ref) {
  final service = ref.watch(searchServiceProvider);
  return service.getDailyPopularSearches(count: 10);
});

/// Unified Multi-Source Parallel Search Provider delegating to SearchService
final unifiedSearchResultsProvider =
    FutureProvider.family<UnifiedSearchResults, String>((ref, query) async {
      final service = ref.watch(searchServiceProvider);
      final surahList = await ref.watch(surahListProvider.future);
      return await service.searchAll(query: query, allSurahs: surahList);
    });
