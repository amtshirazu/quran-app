import 'dart:math';
import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';

class BenefitsCard extends StatelessWidget {
  const BenefitsCard({super.key});

  static const List<String> _kAllBenefits = [
    'Brings peace and tranquility to the heart (Quran 13:28)',
    'Strengthens your connection with Allah',
    'Provides protection from evil and harm',
    'Increases blessings and barakah in your life',
    'Erases sins and elevates your ranks in Jannah',
    'Removes anxiety, sorrow, and mental distress',
    'Attracts Allah\'s remembrance of you (Quran 2:152)',
    'Shields against whisperings of Shaytan',
    'Brings light to the face and joy to the soul',
    'Light on the tongue, heavy on the Scales of Good',
    'Keeps the heart alive and spiritually active',
    'Ensures divine protection during day and night',
  ];

  List<String> _getDailyBenefits() {
    final now = DateTime.now();
    final daySeed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(daySeed);

    final shuffled = List<String>.from(_kAllBenefits)..shuffle(random);
    return shuffled.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final benefits = _getDailyBenefits();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSurface
            : const Color(0xFFFFF9C4).withAlpha(76),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.darkBorder
              : const Color(0xFFFFF176).withAlpha(128),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Benefits of Dhikr',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppTheme.darkTextPrimary
                  : const Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 10),
          ...benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: AppColors.emerald600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      benefit,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : Colors.brown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
