import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/core/theme/app_theme.dart';

class PropheticTipCard extends StatelessWidget {
  const PropheticTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : const Color(0xFFFFF9C4).withAlpha(102),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFFFF176).withAlpha(128),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.emerald600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Tip',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSpacing.size15,
                  color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'The Prophet ﷺ said: "Whoever says \'SubhanAllahi wa bihamdihi\' (Glory and praise be to Allah) one hundred times a day, his sins will be forgiven even if they are like the foam of the sea."',
            style: TextStyle(
              fontSize: AppSpacing.size12,
              height: 1.5,
              color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '- Sahih Al-Bukhari and Muslim',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.emerald600 : Colors.brown,
            ),
          ),
        ],
      ),
    );
  }
}
