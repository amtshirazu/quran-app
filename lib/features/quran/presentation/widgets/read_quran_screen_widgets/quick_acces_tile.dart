import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/models/surah.dart';
import '../../state/quran_providers.dart';

class QuickAccessCard extends ConsumerWidget {
  const QuickAccessCard({
    super.key,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.bgColor,
    required this.fgColor,
    required this.surah,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final Color bgColor;
  final Color fgColor;
  final Surah surah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        ref.read(selectedSurahProvider.notifier).state = surah;
        ref.read(currentPageSurahIdProvider.notifier).state = surah.number;
        context.push("/readAyah");
      },
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.size16),
        ),
        clipBehavior: Clip.antiAlias,

        child: Padding(
          padding: EdgeInsets.all(AppSpacing.size12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: fgColor, size: 20),
              ),

              SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray500,
                      fontSize: AppSpacing.size13,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    sublabel,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray900,
                      fontSize: AppSpacing.size11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
