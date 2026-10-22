import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/audio/domain/models/Reciters.dart';
import 'package:quran_app/features/audio/presentation/state/audio_providers.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';

import '../../../../../core/constants/app_spacing.dart';

class ReciterHeader extends ConsumerWidget {
  const ReciterHeader({super.key, required this.reciter});

  final Reciter reciter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedReciter = ref.watch(selectedReciterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (selectedReciter == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkScaffold : null,
        gradient: isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.deepGreen, AppColors.emerald600],
              ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  final audioProvider = ref.read(audioServiceProvider);
                  await audioProvider.reset();
                  ref.read(selectedReciterProvider.notifier).state = null;
                  ref.read(selectedSurahIndexProvider.notifier).state = 0;
                  ref.read(currentPlayingAyahProvider.notifier).state = null;
                  ref.read(jumpToPageProvider.notifier).state = null;
                  ref.read(targetAyahProvider.notifier).state = null;
                  ref.read(shouldResumeLastReadProvider.notifier).state = false;

                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/audioHome');
                  }
                },
                icon: const Icon(
                  LucideIcons.arrowLeft,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedReciter.name,
                      style: const TextStyle(
                        fontSize: AppSpacing.size16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedReciter.arabicName,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: AppSpacing.size12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
