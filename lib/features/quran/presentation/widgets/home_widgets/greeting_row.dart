import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_app/features/progress/presentation/state/profile_progress_provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';

class GreetingRow extends ConsumerWidget {
  const GreetingRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "As-Salamu Alaykum",
              style: TextStyle(
                color: Colors.white,
                fontSize: AppSpacing.size16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "May peace be upon you",
              style: TextStyle(
                color: AppColors.emerald100,
                fontSize: AppSpacing.size14,
              ),
            ),
          ],
        ),

        InkWell(
          onTap: () {
            ref.invalidate(profileProgressProvider);
            context.go('/profile');
          },
          child: Container(
            width: 65,
            height: 65,
            decoration: const BoxDecoration(
              color: AppColors.emerald500,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          ),
        ),
      ],
    );
  }
}
