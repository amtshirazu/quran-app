import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/constants/app_spacing.dart';

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
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.size16),
      padding: EdgeInsets.all(AppSpacing.size16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.size12),
        // Simple shadow to give the card effect
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Adhan time",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          // Right Side: Time and Toggle controls
          Row(
            children: [
              Text(
                prayerTime,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.emerald600,
                ),
              ),
              SizedBox(width: AppSpacing.size16),
              // Simplified Toggle Row mirroring image_9.png
              Row(
                children: [
                  Icon(
                    isEnabled
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    size: 18,
                    color: isEnabled ? AppColors.emerald600 : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Switch.adaptive(
                    value: isEnabled,
                    activeColor: AppColors.emerald600,
                    onChanged: onToggle,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
