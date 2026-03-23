import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/features/quran/presentation/widgets/home_widgets/quick_access_card.dart';

import '../../../../../core/constants/app_colors.dart';



class QuickAccess extends StatelessWidget {
  const QuickAccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.size16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
        children: const [
          QuickAccessCard(
            bgColor: AppColors.emerald100,
            fgColor: AppColors.emerald600,
            icon: LucideIcons.bookOpen,
            text: "Read Quran",
            route: "/surahs",
          ),
          QuickAccessCard(
            bgColor: AppColors.blue100,
            fgColor: AppColors.blue600,
            icon: LucideIcons.headphones,
            text: "Listen Quran",
            route: "/audioHome",
          ),
          QuickAccessCard(
            bgColor: AppColors.purple100,
            fgColor: AppColors.purple600,
            icon: LucideIcons.bookmark,
            text: "Bookmarks",
            route: "/surahs",
          ),
          QuickAccessCard(
            bgColor: AppColors.pink100,
            fgColor: AppColors.pink600,
            icon: LucideIcons.compass,
            text: "Prayer Times",
            route: "/surahs",
          ),
        ],
      ),
    );
  }
}