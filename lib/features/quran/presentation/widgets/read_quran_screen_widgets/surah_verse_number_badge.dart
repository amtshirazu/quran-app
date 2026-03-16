import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';

import '../../../../../core/constants/app_spacing.dart';






class SurahVerseNumberBadge extends StatelessWidget {
  const SurahVerseNumberBadge({
    super.key,
    required this.surahNumber,
  });

  final int surahNumber;

  @override
  Widget build(BuildContext context) {

    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 60,
      width: 60,
      padding: EdgeInsets.all(AppSpacing.size8),
      decoration: BoxDecoration(
        color: AppColors.emerald600,
        borderRadius: BorderRadius.circular(10),
      ),
      
      child: Center(
        child: Text(
          "$surahNumber",
          style: textTheme.titleLarge,
        ),
      ),

    );
  }
}
