import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/core/theme/app_theme.dart';

class SettingsStepperRow extends StatelessWidget {
  final String title;
  final double value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final Widget previewWidget;
  final bool showDivider;

  const SettingsStepperRow({
    super.key,
    required this.title,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    required this.previewWidget,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppSpacing.size15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.darkTextPrimary : AppColors.gray900,
                    ),
                  ),
                  Row(
                    children: [
                      _buildStepperBtn(context, icon: Icons.remove, onTap: onDecrement),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${value.round()}',
                          style: TextStyle(
                            fontSize: AppSpacing.size15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkTextPrimary : AppColors.gray900,
                          ),
                        ),
                      ),
                      _buildStepperBtn(context, icon: Icons.add, onTap: onIncrement),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141A17) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppColors.gray200,
                  ),
                ),
                child: Center(child: previewWidget),
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

  Widget _buildStepperBtn(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF28322E) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDark ? AppTheme.darkTextPrimary : AppColors.gray900,
        ),
      ),
    );
  }
}
