import 'package:flutter/material.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class ProgressMetric extends StatelessWidget {
  const ProgressMetric({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: isDark ? AppTheme.darkTextPrimary : AppColors.gray900,
            fontSize:  AppSpacing.size20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? AppTheme.darkTextSecondary : AppColors.gray600,
            fontSize:  AppSpacing.size11,
          ),
        ),
      ],
    );
  }
}
