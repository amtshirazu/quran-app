import 'package:flutter/material.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppColors.emerald600.withAlpha(12),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Text(
            index.toString().padLeft(2, '0'),
            style: TextStyle(
              color: isDark ? AppTheme.darkTextSecondary : AppColors.emerald600.withAlpha(76),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          title: Text(
            chapter.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF2D3436),
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.emerald600,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
