import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';

class SettingsSliderRow extends StatelessWidget {
  final String title;
  final double value;
  final ValueChanged<double> onChanged;
  final bool showDivider;

  const SettingsSliderRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppColors.gray900,
                    ),
                  ),
                  Text(
                    '${value.round()}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppColors.gray500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.emerald600,
                  inactiveTrackColor: isDark
                      ? AppTheme.darkBorder
                      : AppColors.gray200,
                  thumbColor: AppColors.emerald600,
                  overlayColor: AppColors.emerald600.withAlpha(38),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: value,
                  min: 10,
                  max: 30,
                  onChanged: onChanged,
                ),
              ),
              Center(
                child: Text(
                  'Preview',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppColors.gray500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? AppTheme.darkBorder : const Color(0xFFF3F4F6),
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
