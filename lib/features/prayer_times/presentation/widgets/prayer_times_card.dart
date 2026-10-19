import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/core/theme/app_theme.dart';

class PrayerTimeCard extends StatelessWidget {
  final String prayerName;
  final String prayerTime;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const PrayerTimeCard({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.size16),
      padding: EdgeInsets.all(AppSpacing.size16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.size12),
        border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side: Name and subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prayerName,
                style: TextStyle(
                  fontSize: AppSpacing.size12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Adhan time",
                style: TextStyle(
                  fontSize: AppSpacing.size12,
                  color: isDark ? AppTheme.darkTextSecondary : Colors.black54,
                ),
              ),
            ],
          ),
          // Right Side: Time and Toggle controls
          Row(
            children: [
              Text(
                prayerTime,
                style: const TextStyle(
                  fontSize: AppSpacing.size15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.emerald600,
                ),
              ),
              SizedBox(width: AppSpacing.size16),
              Row(
                children: [
                  Icon(
                    isEnabled
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    size: 16,
                    color: isEnabled
                        ? AppColors.emerald600
                        : (isDark ? AppTheme.darkTextSecondary : Colors.grey),
                  ),
                  const SizedBox(width: 4),
                  Transform.scale(
                    scale: 0.8, // Adjust between 0.7 and 0.9 depending on desired size
                    child: Switch.adaptive(
                      value: isEnabled,
                      activeTrackColor: AppColors.emerald600,
                      onChanged: onToggle,
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
