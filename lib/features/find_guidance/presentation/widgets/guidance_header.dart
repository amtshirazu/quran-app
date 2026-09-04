import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';

class GuidanceHeader extends StatelessWidget implements PreferredSizeWidget {
  const GuidanceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.emerald600,
      elevation: 0,
      leading: const BackButton(color: Colors.white),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Find verses that speak to your heart',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65);
}
