import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';



class StudyPlanCard extends StatelessWidget {
  const StudyPlanCard({super.key});

  @override
  Widget build(BuildContext context) {

    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(left: 15, right: 15),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.size16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.size20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.blue500,
              AppColors.blue600,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                const Icon(
                  LucideIcons.calendar1,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  "Your Study Plan",
                  style: textTheme.headlineLarge?.copyWith(
                    fontSize: AppSpacing.size18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              "Create a personalized plan for reading, understanding, or memorizing",
              style: TextStyle(
                color: AppColors.blue100, // blue-50
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
                  foregroundColor: AppColors.blue600,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // navigate to study-plan
                },
                child: const Text(
                  "Create Plan",
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