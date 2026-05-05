import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/constants/app_spacing.dart';

class QiblaButton extends StatelessWidget {
  const QiblaButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Implement navigation to Qibla screen
        debugPrint("Navigate to Qibla Finder");
        // context.go('/qibla');
      },
      child: Container(
        padding: EdgeInsets.all(AppSpacing.size16),
        decoration: BoxDecoration(
          color: AppColors.emerald600,
          borderRadius: BorderRadius.circular(AppSpacing.size12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Qibla Direction",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Find direction to Mecca",
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            const Icon(Icons.explore_outlined, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}
