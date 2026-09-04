import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';

class GuidanceSubtitle extends StatelessWidget {
  const GuidanceSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        children: [
          Text(
            'The Quran has guidance for every situation in life.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.gray700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Select how you're feeling to discover relevant verses.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}
