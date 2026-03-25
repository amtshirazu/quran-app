import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../state/audio_providers.dart';

class FeaturedRecitersCard extends ConsumerWidget {

  const FeaturedRecitersCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Featured Reciters",
              style: TextStyle(
                fontSize: AppSpacing.size16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Choose from renowned Quran reciters from around the world",
              style: TextStyle(
                fontSize: AppSpacing.size12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),

            // Search input
            TextField(
              onChanged: (value) {
                ref.read(recitersSearchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: "Search by reciter name or country...",
                hintStyle: TextStyle(
                  fontSize: AppSpacing.size12,
                ),
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.emerald600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}