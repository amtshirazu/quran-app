import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';

class SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppColors.gray200,
          ),
        ),
        elevation: isDark ? 0 : 1,
        shadowColor: Colors.black.withAlpha(15),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }
}
