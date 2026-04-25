import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall completion',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey, // Add this explicitly
                ),
              ),
              Text(
                "${progress.round()}%",
                style: TextStyle(
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
            backgroundColor: AppColors.emerald200,
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
