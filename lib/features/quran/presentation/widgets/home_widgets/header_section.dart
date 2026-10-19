import 'package:flutter/material.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/quran/presentation/widgets/home_widgets/next_prayer_card.dart';
import '../../../../../core/constants/app_spacing.dart';
import 'greeting_row.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 24, 0),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkScaffold : null,
        gradient: isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F382C),
                  Color(0xFF1B5E48),
                ],
              ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppSpacing.size28),
        ),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GreetingRow(),
          SizedBox(height: 30),
          NextPrayerCard(),
        ],
      ),
    );
  }
}
