import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/bookmark/domain/model/bookmark.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_provider.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_service.dart';
import 'package:quran_app/features/bookmark/presentation/widgets/bookmark_note_dialog.dart';
import 'package:quran_app/features/progress/presentation/state/last_read_provider.dart';
import 'package:quran_app/features/progress/presentation/state/profile_progress_provider.dart';
import 'package:quran_app/features/quran/presentation/state/reading_mode.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../audio/presentation/state/audio_providers.dart';
import '../../../state/quran_providers.dart';

class SurahHeaderSection extends ConsumerWidget {
  const SurahHeaderSection({
    super.key,
    required this.controller,
    required this.mode,
  });

  final ReadingMode mode;
  final PageController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSurah = ref.watch(selectedSurahProvider);
    final currentPageSurahAsync = ref.watch(currentPageSurahProvider);
    final textTheme = Theme.of(context).textTheme;
    final audio = ref.read(audioServiceProvider);
    final playerState = ref.watch(audioStreamProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentPage = ref.watch(currentPageProvider);

    final isBookmarked = currentPage != null
        ? ref.watch(isPageBookmarkedProvider((page: currentPage)))
        : false;

    final headerSurah = mode == ReadingMode.reading
        ? currentPageSurahAsync.asData?.value ?? selectedSurah
        : selectedSurah;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 25),
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
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              audio.reset();
              ref.invalidate(lastReadProvider);
              ref.invalidate(lastReadResolvedSurahProvider);
              ref.invalidate(continueReadingProvider);
              ref.invalidate(profileProgressProvider);
              ref.read(currentPageSurahIdProvider.notifier).state = null;
              context.go("/surahs");
            },
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headerSurah?.nameEnglish ?? "",
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: AppSpacing.size16,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  headerSurah?.translation ?? "",
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.gray400,
                    fontSize: AppSpacing.size12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (mode == ReadingMode.reading)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    if (currentPage == null || headerSurah == null) return;

                    final bookmarks = await ref.read(bookmarksProvider.future);

                    Bookmark? existingBookmark;
                    try {
                      existingBookmark = bookmarks.firstWhere(
                            (b) =>
                        b.type == BookmarkType.page &&
                            b.page == currentPage,
                      );
                    } catch (_) {
                      existingBookmark = null;
                    }

                    if (!context.mounted) return;

                    final note = await showBookmarkDialog(
                      context,
                      title: "Add Bookmark",
                      subtitle: "${headerSurah.nameEnglish} • Page $currentPage",
                      initialNote: existingBookmark?.note,
                      isPageMode: true,
                    );

                    if (note == null) return;

                    final service = ref.read(bookmarkServiceProvider);

                    await service.addOrUpdatePageBookmark(
                      page: currentPage,
                      note: note,
                      surahId: headerSurah.number,
                    );

                    ref.invalidate(bookmarksProvider);
                  },
                  icon: Icon(
                    isBookmarked
                        ? LucideIcons.bookmarkCheck
                        : LucideIcons.bookmark,
                    color: isBookmarked ? AppColors.emerald600 : AppColors.gray200,
                    size: 22,
                  ),
                ),
              const SizedBox(width: 12),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  if (headerSurah == null) return;

                  final reciter = ref.read(defaultReciterProvider);
                  final surahs = ref.read(surahListProvider).value;

                  if (playerState?.playing == true) {
                    await audio.pause();
                    return;
                  }

                  if (playerState?.processingState == ProcessingState.completed) {
                    await audio.seekToStart();
                  }

                  final surahIndex = headerSurah.number - 1;
                  final surah = (surahs != null && surahIndex >= 0 && surahIndex < surahs.length)
                      ? surahs[surahIndex]
                      : null;

                  if (!audio.hasLoadedSurah &&
                      reciter != null &&
                      surah != null &&
                      surahs != null) {
                    await audio.playSurah(
                      reciter: reciter,
                      surah: surah,
                      allSurahs: surahs,
                    );
                  } else {
                    await audio.play();
                  }
                },
                icon: Icon(
                  playerState?.playing == true
                      ? LucideIcons.pause
                      : LucideIcons.play,
                  color: AppColors.gray200,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}