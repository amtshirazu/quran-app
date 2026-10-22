import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import '../../../../core/constants/app_spacing.dart';
import '../state/search_provider.dart';
import 'search_chip.dart';

class PopularSearchesSection extends ConsumerWidget {
  final ValueChanged<String> onChipSelected;

  const PopularSearchesSection({super.key, required this.onChipSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularList = ref.watch(popularSearchesProvider);
    final isExpanded = ref.watch(popularSearchesExpandedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayList = isExpanded ? popularList : popularList.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'POPULAR SEARCHES',
              style: TextStyle(
                fontSize: AppSpacing.size13,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppTheme.darkCategoryTitle
                    : const Color(0xFF1F2421),
                letterSpacing: 0.5,
              ),
            ),
            GestureDetector(
              onTap: () {
                ref.read(popularSearchesExpandedProvider.notifier).state =
                    !isExpanded;
              },
              child: Text(
                isExpanded ? 'Show Less' : 'View All',
                style: const TextStyle(
                  color: Color(0xFF1E824C),
                  fontSize: AppSpacing.size12,
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
          children: displayList.map((query) {
            return SearchChip(label: query, onTap: () => onChipSelected(query));
          }).toList(),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}
