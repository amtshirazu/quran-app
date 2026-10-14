import 'package:flutter/material.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';

class ChapterCard extends StatelessWidget {
  final AzkarChapter chapter;
  final int index;
  final VoidCallback onTap;

  const ChapterCard({
    super.key,
    required this.chapter,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppColors.emerald600.withAlpha(12),
          ),
        ),
        elevation: isDark ? 0 : 1,
        shadowColor: Colors.black.withAlpha(15),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          leading: Text(
            index.toString().padLeft(2, '0'),
            style: TextStyle(
              color: isDark ? AppTheme.darkTextSecondary : AppColors.emerald600.withAlpha(76),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          title: Text(
            chapter.name,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF2D3436),
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 13,
            color: AppColors.emerald600,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
