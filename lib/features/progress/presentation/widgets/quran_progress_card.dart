import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import 'progress_metric.dart';

class QuranProgressCard extends StatelessWidget {
  const QuranProgressCard({
    super.key,
    required this.progress,
    required this.streak,
    required this.verses,
    required this.surahs,
  });

  final double progress;
  final int streak;
  final int verses;
  final int surahs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quran Progress',
            style: TextStyle(
              fontSize:  AppSpacing.size15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall completion',
                style: TextStyle(
                  fontSize:  AppSpacing.size11,
                  color: isDark ? AppTheme.darkTextSecondary : Colors.grey,
                ),
              ),
              Text(
                "${progress.round()}%",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.emerald600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: isDark ? AppTheme.darkBorder : AppColors.emerald200,
            valueColor: const AlwaysStoppedAnimation(AppColors.emerald600),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: ProgressMetric(
                  icon: LucideIcons.trendingUp,
                  iconColor: AppColors.emerald600,
                  value: streak.toString(),
                  label: 'Day Streak',
                ),
              ),
              Expanded(
                child: ProgressMetric(
                  icon: LucideIcons.bookOpen,
                  iconColor: AppColors.emerald600,
                  value: verses.toString(),
                  label: 'Verses Read',
                ),
              ),
              Expanded(
                child: ProgressMetric(
                  icon: LucideIcons.calendar,
                  iconColor: AppColors.emerald600,
                  value: surahs.toString(),
                  label: 'Surahs',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
