import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/search_result.dart';
import '../state/search_provider.dart';

class SearchTabsBar extends ConsumerWidget {
  final UnifiedSearchResults results;

  const SearchTabsBar({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(searchTabFilterProvider);

    final tabs = [
      _TabItem(
        tab: SearchTab.all,
        label: 'ALL (${results.totalCount})',
      ),
      _TabItem(
        tab: SearchTab.ayah,
        label: 'AYAH (${results.ayahs.length})',
      ),
      _TabItem(
        tab: SearchTab.surah,
        label: 'SURAH (${results.surahs.length})',
      ),
      _TabItem(
        tab: SearchTab.azkaar,
        label: 'AZKAAR (${results.azkaar.length})',
      ),
      _TabItem(
        tab: SearchTab.dua,
        label: 'DUA (${results.duas.length})',
      ),
    ];

    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: tabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = tabs[index];
          final isSelected = activeTab == item.tab;

          return GestureDetector(
            onTap: () {
              ref.read(searchTabFilterProvider.notifier).state = item.tab;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0F382C) // Dark green active
                    : const Color(0xFFEFECE6), // Soft beige inactive
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.0,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF1F2421),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TabItem {
  final SearchTab tab;
  final String label;

  const _TabItem({
    required this.tab,
    required this.label,
  });
}
