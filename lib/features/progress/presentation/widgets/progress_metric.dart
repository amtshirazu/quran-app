import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';



class ProgressMetric extends StatelessWidget {
  const ProgressMetric({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.gray900,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.gray600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}