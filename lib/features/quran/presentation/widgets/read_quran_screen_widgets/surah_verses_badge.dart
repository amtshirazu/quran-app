import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';

import '../../../../../core/constants/app_spacing.dart';






class SurahVersesBadge extends StatelessWidget {
  const SurahVersesBadge({
    super.key,
    required this.totalAyahs,
  });

  final int totalAyahs;

  @override
  Widget build(BuildContext context) {

    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 40,
      width: 100,
      padding: EdgeInsets.all(AppSpacing.size8),
      decoration: BoxDecoration(
        color: AppColors.gray400.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Center(
        child: Text(
          "$totalAyahs verses",
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.gray900,
          ),
        ),
      ),

    );
  }
}
