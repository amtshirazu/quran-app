import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';

class SettingsRow extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const SettingsRow({
    super.key,
    this.icon,
    this.iconWidget,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trailingWidget = trailing;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                if (iconWidget != null) ...[
                  iconWidget!,
                  const SizedBox(width: 12),
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    color: isDark ? AppTheme.darkTextSecondary : AppColors.gray600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.darkTextPrimary : AppColors.gray900,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.darkTextSecondary : AppColors.gray500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ?trailingWidget,
              ],
            ),
          ),
        ),
        SizedBox(height: 2,),
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
