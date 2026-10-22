import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/model/guidance_category.dart';

class GuidanceFeelingCard extends StatelessWidget {
  final GuidanceCategory category;
  final VoidCallback onTap;

  const GuidanceFeelingCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppColors.gray200,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark
                        ? category.iconColor.withAlpha(38)
                        : category.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.emotion,
                        style: TextStyle(
                          fontSize: AppSpacing.size13,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.verseCount} ${category.verseCount == 1 ? 'verse' : 'verses'}',
                        style: TextStyle(
                          fontSize: AppSpacing.size11,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppColors.gray400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
