import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';

class StudyPlanCard extends StatelessWidget {
  const StudyPlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(left: 15, right: 15),
      elevation: isDark ? 0 : 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.size16),
        side: isDark ? const BorderSide(color: AppTheme.darkBorder) : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
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
                  colors: [
                    AppColors.deepGreen,
                    AppColors.emerald600,
                  ],
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.calendar1,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  "Your Study Plan",
                  style: textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontSize: AppSpacing.size16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Create a personalized plan for reading, understanding, or memorizing",
              style: TextStyle(
                color: AppColors.emerald100,
                fontSize: AppSpacing.size12,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.emerald600 : Colors.white,
                  foregroundColor: isDark ? Colors.white : AppColors.emerald600,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Create Plan",
                  style: TextStyle(
                    fontSize: AppSpacing.size12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
