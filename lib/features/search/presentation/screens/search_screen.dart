import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import '../state/search_provider.dart';
import '../widgets/popular_searches_section.dart';
import '../widgets/recent_searches_section.dart';
import '../widgets/search_header.dart';
import '../widgets/search_results_view.dart';
import '../widgets/search_tabs_bar.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeSearchQueryProvider.notifier).state = '';
      ref.read(searchTabFilterProvider.notifier).state = SearchTab.all;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _executeSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return;

    setState(() {
      _searchController.text = trimmed;
    });
    ref.read(activeSearchQueryProvider.notifier).state = trimmed;

    final service = ref.read(searchServiceProvider);
    await service.addRecentSearch(trimmed);

    ref.invalidate(recentSearchesProvider);
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
    });
    ref.read(activeSearchQueryProvider.notifier).state = '';
    ref.read(searchTabFilterProvider.notifier).state = SearchTab.all;
    ref.invalidate(recentSearchesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final activeQuery = ref.watch(activeSearchQueryProvider).trim();
    final isSearching = activeQuery.length >= 2;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SearchHeader(
        controller: _searchController,
        onSearchSubmitted: _executeSearch,
        onClear: _clearSearch,
      ),
      body: isSearching
          ? _buildSearchResults(activeQuery)
          : _buildInitialDashboard(),
    );
  }

  Widget _buildInitialDashboard() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecentSearchesSection(onChipSelected: _executeSearch),
          PopularSearchesSection(onChipSelected: _executeSearch),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSearchResults(String query) {
    final resultsAsync = ref.watch(unifiedSearchResultsProvider(query));

    return resultsAsync.when(
      data: (results) {
        return Column(
          children: [
            SearchTabsBar(results: results),
            Expanded(child: SearchResultsView(results: results)),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: CircularProgressIndicator(color: AppColors.emerald600),
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Error performing search: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
