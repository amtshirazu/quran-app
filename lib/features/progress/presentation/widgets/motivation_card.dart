import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/features/progress/presentation/state/profile_progress_provider.dart';

import '../../../../core/constants/app_spacing.dart';

class MotivationCard extends ConsumerWidget {
  final String? title;
  final String? subtitle;

  const MotivationCard({
    super.key,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String displayTitle = title ?? ref.watch(motivationTitleProvider);
    final String displaySubtitle = subtitle ?? ref.watch(motivationSubtitleProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.deepGreen, AppColors.emerald600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald600.withAlpha(51),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Text(
                displayTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppSpacing.size16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            displaySubtitle,
            style: const TextStyle(
              color: AppColors.emerald100,
              fontSize:  AppSpacing.size11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
