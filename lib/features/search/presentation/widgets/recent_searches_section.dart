import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import '../state/search_provider.dart';
import 'search_chip.dart';

class RecentSearchesSection extends ConsumerWidget {
  final ValueChanged<String> onChipSelected;

  const RecentSearchesSection({super.key, required this.onChipSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentSearchesAsync = ref.watch(recentSearchesProvider);
    final isExpanded = ref.watch(recentSearchesExpandedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return recentSearchesAsync.when(
      data: (searches) {
        if (searches.isEmpty) {
          return const SizedBox.shrink();
        }

        final displayList = isExpanded
            ? searches.take(8).toList()
            : searches.take(4).toList();

        final hasMoreThanFour = searches.length > 4;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT SEARCHES',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppTheme.darkCategoryTitle
                        : const Color(0xFF1F2421),
                    letterSpacing: 0.5,
                  ),
                ),
                if (hasMoreThanFour)
                  GestureDetector(
                    onTap: () {
                      ref.read(recentSearchesExpandedProvider.notifier).state =
                          !isExpanded;
                    },
                    child: Text(
                      isExpanded ? 'Show Less' : 'View All',
                      style: const TextStyle(
                        color: Color(0xFF1E824C),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: displayList.map((item) {
                return SearchChip(
                  label: item.query,
                  onTap: () => onChipSelected(item.query),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
