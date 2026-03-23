import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_spacing.dart';

import '../../../../../core/constants/app_colors.dart';





class QuickAccessCard extends StatelessWidget {
  const QuickAccessCard({
    super.key,
    required this.icon,
    required this.text,
    required this.bgColor,
    required this.fgColor,
    required this.route,
  });

  final IconData icon;
  final String text;
  final Color bgColor;
  final Color fgColor;
  final String route;

  @override
  Widget build(BuildContext context) {

    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => context.push(route),
      child: Card(
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.size16),
          ),
          clipBehavior: Clip.antiAlias,

          child: Padding(
            padding: EdgeInsets.all(AppSpacing.size10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                    size: 22,
                  ),
                ),

                SizedBox(height: 30),

                Text(
                  text,
                  style: textTheme.headlineLarge?.copyWith(
                    color: AppColors.gray900,
                    fontSize: AppSpacing.size14,
                  ),
                )
              ],
            ),
          ),
        ),
    );
  }
}
