import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';

class EmptyCard extends StatelessWidget {
  const EmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark
            ? const BorderSide(color: AppTheme.darkBorder)
            : BorderSide.none,
      ),
      color: isDark ? AppTheme.darkSurface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Continue Reading',
              style: TextStyle(
                fontSize: AppSpacing.size15,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  const Icon(
                    LucideIcons.bookOpen,
                    size: 40,
                    color: AppColors.emerald600,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Start reading to continue',
                    style: TextStyle(
                      fontSize: AppSpacing.size12,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/surahs');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Start Reading',
                      style: TextStyle(
                        fontSize: AppSpacing.size11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
