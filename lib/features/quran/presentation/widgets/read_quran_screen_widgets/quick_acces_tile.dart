import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';





class QuickAccessCard extends StatelessWidget {
  const QuickAccessCard({
    super.key,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.bgColor,
    required this.fgColor,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final Color bgColor;
  final Color fgColor;

  @override
  Widget build(BuildContext context) {

    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {

      },
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,

        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: fgColor,
                    size: 24,
                  ),
                ),

                SizedBox(width: 6),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      sublabel,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
      ),
    );
  }
}
