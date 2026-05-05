import 'package:flutter/material.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/constants/app_spacing.dart';

class SelectedButton extends StatefulWidget {
  const SelectedButton({
    super.key,
    required this.text,
    required this.icon,
    this.onTap, // Callback added
  });

  final String text;
  final IconData icon;
  final VoidCallback? onTap; // Callback added

  @override
  State<SelectedButton> createState() => _SelectedButtonState();
}

class _SelectedButtonState extends State<SelectedButton> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            isTapped = !isTapped;
          });
          // Trigger the logic passed from the parent
          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: isTapped ? AppColors.gray200 : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.size12),
            border: Border.all(color: AppColors.gray200, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 18, color: AppColors.gray900),
              const SizedBox(width: 8),
              Text(
                widget.text,
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
