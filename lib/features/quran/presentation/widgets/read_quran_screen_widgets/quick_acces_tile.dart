import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/audio/presentation/state/audio_providers.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        final audio = ref.read(audioServiceProvider);
        audio.stop();
        audio.clearActiveState();

        ref.read(jumpToPageProvider.notifier).state = null;
        ref.read(targetAyahProvider.notifier).state = null;
        ref.read(currentPlayingAyahProvider.notifier).state = null;
        ref.read(shouldResumeLastReadProvider.notifier).state = false;

        ref.read(selectedSurahProvider.notifier).state = surah;
        ref.read(explicitSurahSelectionProvider.notifier).state = surah;
        ref.read(currentPageSurahIdProvider.notifier).state = surah.number;

        context.push("/readAyah");
      },
      child: Card(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        elevation: isDark ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.size16),
          side: isDark
              ? const BorderSide(color: AppTheme.darkBorder)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.size12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isDark ? fgColor.withAlpha(38) : bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: fgColor, size: 20),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppColors.gray500,
                      fontSize: AppSpacing.size13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sublabel,
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppColors.gray900,
                      fontSize: AppSpacing.size11,
                      fontWeight: FontWeight.bold,
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
