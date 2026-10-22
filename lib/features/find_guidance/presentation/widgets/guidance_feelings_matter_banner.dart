import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';

import '../../../../core/constants/app_spacing.dart';

class GuidanceFeelingsMatterBanner extends StatelessWidget {
  const GuidanceFeelingsMatterBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : null,
        gradient: isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.deepGreen, AppColors.emerald600],
              ),
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
      ),
      child: Column(
        children: const [
          Icon(LucideIcons.heart, color: Colors.white, size: 32),
          SizedBox(height: 12),
          Text(
            'Your feelings matter',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSpacing.size16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Allah knows what's in your heart. Turn to the Quran for comfort, guidance, and strength.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.emerald100,
              fontSize: AppSpacing.size12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
