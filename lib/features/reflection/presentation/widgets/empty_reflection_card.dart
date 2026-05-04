import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EmptyReflectionsCard extends StatelessWidget {
  const EmptyReflectionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    const colorMidGray = Color(0xFF4A4A4A);
    const colorLightGray = Color(0xFFD1D5DB); // Neutral gray for the icon
    const colorAmber = Color(0xFFD97706); // Primary button color

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large Placeholder Icon
          Icon(
            LucideIcons.notebookPen,
            size: 64,
            color: colorLightGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),

          // Primary Label
          const Text(
            "No reflections yet",
            style: TextStyle(
              fontSize: 16,
              color: colorMidGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // Action Button
          ElevatedButton(
            onPressed: () {
              // Navigate to your Quran reading screen
              context.go('/surahs');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorAmber,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Start Reading & Reflecting",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
