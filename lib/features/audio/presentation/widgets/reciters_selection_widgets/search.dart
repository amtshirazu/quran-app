import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../state/audio_providers.dart';

class FeaturedRecitersCard extends ConsumerWidget {
  const FeaturedRecitersCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      elevation: isDark ? 0 : 1,
      color: isDark ? AppTheme.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark ? const BorderSide(color: AppTheme.darkBorder) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Featured Reciters",
              style: TextStyle(
                fontSize: AppSpacing.size13,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Choose from renowned Quran reciters from around the world",
              style: TextStyle(
                fontSize: AppSpacing.size10,
                color: isDark ? AppTheme.darkTextSecondary : Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 38, // Adjust overall height here (e.g. 36 - 40)
              child: TextField(
                onChanged: (value) {
                  ref.read(recitersSearchQueryProvider.notifier).state = value;
                },
                style: TextStyle(
                  color: isDark ? AppTheme.darkTextPrimary : Colors.black,
                  fontSize: AppSpacing.size10,
                ),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: "Search by reciter name or country...",
                  hintStyle: TextStyle(
                    fontSize: AppSpacing.size10,
                    color: isDark ? AppTheme.darkTextSecondary : Colors.grey,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 8),
                    child: Icon(
                      LucideIcons.search,
                      size: 14,
                      color: isDark ? AppTheme.darkTextSecondary : Colors.grey,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark ? AppTheme.darkBorder : Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark ? AppTheme.darkBorder : Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.emerald600),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
