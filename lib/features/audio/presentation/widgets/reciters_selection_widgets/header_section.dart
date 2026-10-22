import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';

class QuranAudioHeader extends ConsumerWidget {
  final int recitersCount;

  const QuranAudioHeader({super.key, required this.recitersCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkScaffold : null,
          gradient: isDark
              ? null
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.deepGreen, AppColors.emerald600],
                ),
          border: const Border(
            bottom: BorderSide(color: Colors.black12, width: 1),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 48, 20, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Quran Audio",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSpacing.size16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Listen to beautiful recitations",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: AppSpacing.size12,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.star,
                    size: AppSpacing.size13,
                    color: AppColors.emerald600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "$recitersCount Reciters",
                    style: const TextStyle(
                      color: AppColors.emerald600,
                      fontSize: AppSpacing.size11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
