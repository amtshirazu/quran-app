import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';

import '../../../../core/constants/app_spacing.dart';

class EmptyReflectionsCard extends StatelessWidget {
  const EmptyReflectionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : Colors.grey.shade100,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.notebookPen,
            size: 50,
            color: isDark ? AppTheme.darkTextSecondary : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "No reflections yet",
            style: TextStyle(
              fontSize: AppSpacing.size14,
              color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF4A4A4A),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.go('/surahs');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald600,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Start Reading & Reflecting",
              style: TextStyle(fontSize: AppSpacing.size12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
