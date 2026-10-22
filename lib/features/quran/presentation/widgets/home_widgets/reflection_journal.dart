import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/reflection/presentation/states/reflection_provider.dart';
import '../../../../../core/constants/app_colors.dart';

class ReflectionJournalCard extends ConsumerWidget {
  const ReflectionJournalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reflectionStats = ref.watch(reflectionStatsProvider);
    final totalCount = reflectionStats['thisWeek'].toString();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 25, top: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.size16),
        side: isDark
            ? const BorderSide(color: AppTheme.darkBorder)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      elevation: isDark ? 0 : 6,
      color: isDark ? AppTheme.darkSurface : null,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.size20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : null,
          gradient: isDark
              ? null
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.deepGreen, AppColors.emerald600],
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.notebook,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Reflection Journal",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: AppSpacing.size15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$totalCount reflections this week",
                      style: const TextStyle(
                        color: AppColors.emerald100,
                        fontSize: AppSpacing.size10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                context.push('/reflections');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: isDark
                    ? AppColors.emerald600
                    : Colors.white.withAlpha(26),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.size12),
                ),
              ),
              child: const Text(
                "View All",
                style: TextStyle(fontSize: AppSpacing.size10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
