import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';

import '../../../../../core/constants/app_spacing.dart';

class AzkaarDuaCard extends StatelessWidget {
  const AzkaarDuaCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 12, top: 6),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : null,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
        gradient: isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.deepGreen, AppColors.emerald600],
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(LucideIcons.sparkles, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                "Azkaar and Dua",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Daily remembrance and supplications from the Quran and Sunnah",
            style: TextStyle(
              color: AppColors.emerald100,
              fontSize: AppSpacing.size12,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.push('/azkaarAndDua');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.emerald600 : Colors.white,
                foregroundColor: isDark ? Colors.white : AppColors.emerald600,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text(
                "Explore",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSpacing.size12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
