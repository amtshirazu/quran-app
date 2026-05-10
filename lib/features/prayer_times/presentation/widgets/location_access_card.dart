import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/constants/app_spacing.dart';

class LocationAccessCard extends StatelessWidget {
  final VoidCallback onEnablePressed;

  const LocationAccessCard({super.key, required this.onEnablePressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.emerald500.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppSpacing.size20),
        border: Border.all(
          color: AppColors.emerald500.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.emerald500.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.navigation,
              color: AppColors.emerald600,
              size: 28,
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            "Location Access Required",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            "We need your location to show accurate prayer times for your area. Please enable location access to continue.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onEnablePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(LucideIcons.mapPin, size: 18),
              label: const Text(
                "Enable Location Access",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Privacy Footer
          Text(
            "Your location is only used to calculate prayer times and is not stored.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black45,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
