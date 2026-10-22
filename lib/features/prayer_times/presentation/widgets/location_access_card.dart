import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/core/theme/app_theme.dart';

class LocationAccessCard extends StatelessWidget {
  final VoidCallback onEnablePressed;

  const LocationAccessCard({super.key, required this.onEnablePressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.emerald600.withAlpha(26)
            : AppColors.emerald500.withAlpha(20),
        borderRadius: BorderRadius.circular(AppSpacing.size20),
        border: Border.all(
          color: isDark
              ? AppTheme.darkBorder
              : AppColors.emerald500.withAlpha(51),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.emerald600.withAlpha(38)
                  : AppColors.emerald500.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.navigation,
              color: AppColors.emerald600,
              size: 24,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Location Access Required",
            style: TextStyle(
              fontSize: AppSpacing.size15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "We need your location to show accurate prayer times for your area. Please enable location access to continue.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSpacing.size12,
              color: isDark ? AppTheme.darkTextSecondary : Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onEnablePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(LucideIcons.mapPin, size: 16),
              label: const Text(
                "Enable Location Access",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppSpacing.size12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Your location is only used to calculate prayer times and is not stored.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSpacing.size10,
              color: isDark ? AppTheme.darkTextSecondary : Colors.black45,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
