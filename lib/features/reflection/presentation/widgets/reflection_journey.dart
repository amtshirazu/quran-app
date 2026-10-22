import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';

import '../../../../core/constants/app_spacing.dart';

class ReflectionJourneyCard extends StatelessWidget {
  const ReflectionJourneyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : null,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
        gradient: isDark
            ? null
            : const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.deepGreen, AppColors.emerald600],
              ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              LucideIcons.notebookPen,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Your Personal Journey",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppSpacing.size14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Write reflections as you read the Quran. Track your spiritual growth and insights over time.",
                  style: TextStyle(
                    color: AppColors.emerald100,
                    fontSize: AppSpacing.size11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
