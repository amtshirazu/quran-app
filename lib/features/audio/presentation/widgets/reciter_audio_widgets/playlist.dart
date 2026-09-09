import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/audio/presentation/widgets/reciter_audio_widgets/playlist_cards.dart';
import '../../../../quran/presentation/state/quran_providers.dart';

class Playlist extends ConsumerWidget {
  const Playlist({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: Card(
        margin: const EdgeInsets.only(right: 16, left: 16, bottom: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isDark ? const BorderSide(color: AppTheme.darkBorder) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        elevation: isDark ? 0 : 1,
        color: isDark ? AppTheme.darkSurface : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                "Playlist",
                style: TextStyle(
                  fontSize: AppSpacing.size16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : Colors.black,
                ),
              ),
            ),
            surahsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.emerald600),
                ),
              ),
              error: (e, st) => Padding(
                padding: const EdgeInsets.all(16),
                child: Center(child: Text("Error loading playlist: $e")),
              ),
              data: (surahs) => Container(
                constraints: const BoxConstraints(
                  maxHeight: 450,
                ),
                child: PlaylistCard(surahs: surahs),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
