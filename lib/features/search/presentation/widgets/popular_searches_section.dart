import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/search_provider.dart';
import 'search_chip.dart';

class PopularSearchesSection extends ConsumerWidget {
  final ValueChanged<String> onChipSelected;

  const PopularSearchesSection({
    super.key,
    required this.onChipSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularList = ref.watch(popularSearchesProvider);
    final isExpanded = ref.watch(popularSearchesExpandedProvider);

    final displayList = isExpanded ? popularList : popularList.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'POPULAR SEARCHES',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2421), // Dark charcoal
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
                  color: Color(0xFF1E824C), // Accent green
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        /// Wrap Chips Layout
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: displayList.map((query) {
            return SearchChip(
              label: query,
              onTap: () => onChipSelected(query),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}
