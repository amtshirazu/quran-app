import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../../core/constants/app_colors.dart';


class SelectedButton extends StatefulWidget {
  const SelectedButton({
    super.key,
    required this.text,
    required this.icon,
  });

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
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            color: isTapped ? AppColors.gray200 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.gray200,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: AppColors.gray900,
              ),
              SizedBox(width: 8),
              Text(text,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray900,
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
