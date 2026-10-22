import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';

import '../../../../core/constants/app_spacing.dart';

class GuidanceSubtitle extends StatelessWidget {
  const GuidanceSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        children: [
          Text(
            'The Quran has guidance for every situation in life.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSpacing.size13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.darkTextPrimary : AppColors.gray700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Select how you're feeling to discover relevant verses.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSpacing.size12,
              color: isDark ? AppTheme.darkTextSecondary : AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}
