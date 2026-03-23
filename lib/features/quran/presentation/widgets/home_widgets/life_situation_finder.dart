import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';



class LifeSituationCard extends StatelessWidget {
  const LifeSituationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 25, left: 15, right: 15),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,

      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.purple500,
              AppColors.purple500,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Icon(
                  LucideIcons.lightbulb,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  "How are you feeling?",
                  style: textTheme.headlineLarge?.copyWith(
                    fontSize: AppSpacing.size18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              "Find verses that speak to your heart right now",
              style: TextStyle(
                color: AppColors.emerald50,
                fontSize: AppSpacing.size14,
              ),
            ),

            const SizedBox(height: 16),

            /// Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.purple600,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // navigate to life-situation
                },
                child: const Text(
                  "Find Guidance",
                  style: TextStyle(
                    fontSize: AppSpacing.size14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}