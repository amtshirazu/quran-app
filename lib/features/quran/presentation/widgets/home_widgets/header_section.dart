import 'package:flutter/material.dart';
import 'package:quran_app/features/quran/presentation/widgets/home_widgets/next_prayer_card.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import 'greeting_row.dart';


class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
      decoration: const BoxDecoration(
        color: AppColors.emerald600,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppSpacing.size28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          GreetingRow(),
          SizedBox(height: 30),
          NextPrayerCard(),
        ],
      ),
    );
  }
}