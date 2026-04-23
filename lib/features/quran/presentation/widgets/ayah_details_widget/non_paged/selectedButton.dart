import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_spacing.dart';

class SelectedButton extends StatefulWidget {
  const SelectedButton({super.key, required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  State<SelectedButton> createState() => _SelectedButtonState();
}

class _SelectedButtonState extends State<SelectedButton> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final text = widget.text;
    final icon = widget.icon;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            isTapped = !isTapped;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: isTapped ? AppColors.gray200 : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.size12),
            border: Border.all(color: AppColors.gray200, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.gray900),
              SizedBox(width: 8),
              Text(
                text,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray900,
                  fontSize: AppSpacing.size11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
