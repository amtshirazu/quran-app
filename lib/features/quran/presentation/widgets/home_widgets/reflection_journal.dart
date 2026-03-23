import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_spacing.dart';

import '../../../../../core/constants/app_colors.dart';



class ReflectionJournalCard extends StatelessWidget {
  const ReflectionJournalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 50 , top: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.size16),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 6,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.size20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.amber500,
              AppColors.amber600,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.notebook,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Reflection Journal",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: AppSpacing.size16,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "3 reflections this week",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: AppSpacing.size12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Right side: button
            TextButton(
              onPressed: () {
                // navigate to /reflections
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.1),
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.size12),
                ),
              ),
              child: const Text(
                "View All",
                style: TextStyle(fontSize: AppSpacing.size14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}