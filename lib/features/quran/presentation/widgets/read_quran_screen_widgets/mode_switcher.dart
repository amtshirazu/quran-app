import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/features/quran/presentation/state/reading_mode.dart';

import '../../../../../core/constants/app_spacing.dart';





class ModeSwitcher extends StatelessWidget {
  const ModeSwitcher({
    super.key,
    required this.mode,
    required this.onChanged
  });

  final ReadingMode mode;
  final Function(ReadingMode) onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 205,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.size8),
        decoration: BoxDecoration(
          color: AppColors.gray700,
          borderRadius: BorderRadius.circular(AppSpacing.size30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildButton("Translation", ReadingMode.translation),
            buildButton("Reading", ReadingMode.reading),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String text, ReadingMode newMode) {

    return GestureDetector(
      onTap: () => onChanged(newMode),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical : 8),
        decoration: BoxDecoration(
          color: mode == newMode ? AppColors.emerald500.withOpacity(0.5): Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: mode == newMode ? Colors.white : AppColors.gray300,
              fontWeight: FontWeight.w600,
              fontSize: AppSpacing.size12,
            ),
          ),
        ),
      )
    );
  }
}
