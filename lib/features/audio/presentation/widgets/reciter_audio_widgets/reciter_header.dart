import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/audio/domain/models/Reciters.dart';
import 'package:quran_app/features/audio/presentation/state/audio_providers.dart';

class ReciterHeader extends ConsumerWidget {
  const ReciterHeader({super.key, required this.reciter});

  final Reciter reciter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedReciter = ref.watch(selectedReciterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (selectedReciter == null) return const SizedBox.shrink();

    return Container(
      color: isDark ? AppTheme.darkScaffold : AppColors.emerald600,
      height: 160,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () async {
                final audioProvider = ref.read(audioServiceProvider);
                audioProvider.setUserSelecting(true);
                await audioProvider.reset();
                ref.read(selectedReciterProvider.notifier).state = null;
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/audioHome');
                }
              },
              icon: const Icon(
                LucideIcons.arrowLeft,
                size: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedReciter.name,
                    style: const TextStyle(
                      fontSize: AppSpacing.size18,
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
                      fontSize: AppSpacing.size14,
                      color: Colors.white70,
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
