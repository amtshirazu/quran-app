import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';

class QuickAccessCard extends StatelessWidget {
  const QuickAccessCard({
    super.key,
    required this.icon,
    required this.text,
    required this.bgColor,
    required this.fgColor,
    required this.route,
  });

  final IconData icon;
  final String text;
  final Color bgColor;
  final Color fgColor;
  final String route;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.zero,
      color: isDark ? AppTheme.darkSurface : Colors.white,
      elevation: isDark ? 0 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark
            ? const BorderSide(color: AppTheme.darkBorder)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(route),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? fgColor.withAlpha(38) : bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: fgColor, size: 18),
              ),
              const SizedBox(height: 24),
              Text(
                text,
                style: TextStyle(
                  color: isDark ? AppTheme.darkTextPrimary : AppColors.gray900,
                  fontSize: AppSpacing.size12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
