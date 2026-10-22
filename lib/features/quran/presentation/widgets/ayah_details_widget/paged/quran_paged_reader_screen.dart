import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart' hide Surah;
import 'package:quran/quran.dart' as quran;
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/audio/presentation/state/audio_providers.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_provider.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_service.dart';
import 'package:quran_app/features/bookmark/presentation/widgets/bookmark_note_dialog.dart';
import 'package:quran_app/features/progress/presentation/state/last_read_provider.dart';
import 'package:quran_app/features/progress/presentation/state/profile_progress_provider.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/non_paged/tafseer_bottom_sheet.dart';
import 'package:quran_app/features/settings/presentation/state/display_settings_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../domain/models/surah.dart';
import '../../../state/quran_providers.dart';

class QuranPagedReaderScreen extends ConsumerStatefulWidget {
  const QuranPagedReaderScreen({super.key, required this.controller});

  final PageController controller;

  @override
  ConsumerState<QuranPagedReaderScreen> createState() =>
      _QuranPagedReaderScreenState();
}

class _QuranPagedReaderScreenState
    extends ConsumerState<QuranPagedReaderScreen> {
  Timer? _dwellTimer;
  static const Duration _pagedDwellThreshold = Duration(seconds: 15);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final startPage =
          widget.controller.hasClients && widget.controller.page != null
          ? widget.controller.page!.round() + 1
          : widget.controller.initialPage + 1;

      _handlePageSelected(startPage);
    });
  }

  Future<void> _handlePageSelected(int pageNumber) async {
    ref.read(currentPageProvider.notifier).state = pageNumber;

    final pageEntries = quran.getPageData(pageNumber);
    final surahsOnPage = pageEntries.map((e) => e['surah'] as int).toList();

    // Multi-Surah Page Resolution: Case A vs Case B
    final explicitSurah = ref.read(explicitSurahSelectionProvider);
    int? surahId;

    if (explicitSurah != null) {
      if (surahsOnPage.contains(explicitSurah.number)) {
        // Case A: Explicit Surah selection is preserved while navigating its pages
        surahId = explicitSurah.number;
      } else {
        // User swiped to a page where explicit surah is no longer present
        ref.read(explicitSurahSelectionProvider.notifier).state = null;
      }
    }

    if (surahId == null) {
      // Case B: Swiped / scrolled into view -> derive from topmost verse on page
      if (surahsOnPage.isNotEmpty) {
        surahId = pageEntries.first['surah'] as int;
      } else {
        final progress = ref.read(progressServiceProvider);
        surahId = await progress.resolveActiveSurah(
          mode: 'page',
          page: pageNumber,
        );
      }
    }

    if (surahId != null) {
      ref.read(currentPageSurahIdProvider.notifier).state = surahId;

      final surahsAsync = ref.read(surahListProvider);
      if (surahsAsync is AsyncData<List<Surah>>) {
        try {
          final foundSurah = surahsAsync.value.firstWhere(
            (s) => s.number == surahId,
          );
          ref.read(selectedSurahProvider.notifier).state = foundSurah;
        } catch (_) {}
      }
    }

    // 1. Instantly register place-marker so Continue Reading works immediately
    final progress = ref.read(progressServiceProvider);
    await progress.setBookmarkImmediate(
      mode: 'page',
      page: pageNumber,
      surahId: surahId,
    );

    _invalidateProgressProviders();

    // 2. Start the dwell countdown for reading credit and streak
    _startDwellTimer(pageNumber);
  }

  void _startDwellTimer(int pageNumber) {
    _dwellTimer?.cancel();

    _dwellTimer = Timer(_pagedDwellThreshold, () async {
      if (!mounted) return;

      final progress = ref.read(progressServiceProvider);
      await progress.updateStreak();
      await progress.trackPage(pageNumber);

      _invalidateProgressProviders();
    });
  }

  void _invalidateProgressProviders() {
    ref.invalidate(lastReadProvider);
    ref.invalidate(lastReadResolvedSurahProvider);
    ref.invalidate(profileProgressProvider);
    ref.invalidate(continueReadingProvider);
  }

  void _showAyahActionBottomSheet({
    required int surahNumber,
    required int verseNumber,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surahName = quran.getSurahName(surahNumber);
    final arabicText = quran.getVerse(surahNumber, verseNumber);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkBorder
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.emerald600.withAlpha(40)
                              : AppColors.emerald100,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$verseNumber',
                            style: const TextStyle(
                              color: AppColors.emerald600,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Surah $surahName, Verse $verseNumber',
                              style: TextStyle(
                                fontSize: AppSpacing.size13,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppTheme.darkTextPrimary
                                    : AppColors.gray900,
                              ),
                            ),
                            Text(
                              'Select an action',
                              style: TextStyle(
                                fontSize: AppSpacing.size10,
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 110),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkScaffold : AppColors.gray100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        arabicText,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Uthmanic',
                          fontSize: AppSpacing.size14,
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppColors.gray900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: const Icon(
                      LucideIcons.volume2,
                      color: AppColors.emerald600,
                      size: 18,
                    ),
                    title: const Text(
                      'Listen to Verse Audio',
                      style: TextStyle(
                        fontSize: AppSpacing.size12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final audio = ref.read(audioServiceProvider);
                      final reciter = ref.read(defaultReciterProvider);
                      final surahs = ref.read(surahListProvider).value;
                      final surahObj = surahs?.firstWhere(
                        (s) => s.number == surahNumber,
                      );
                      if (reciter != null && surahObj != null) {
                        await audio.playVerse(
                          reciter: reciter,
                          surah: surahObj,
                          ayah: verseNumber,
                        );
                      }
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: const Icon(
                      LucideIcons.bookOpen,
                      color: AppColors.emerald600,
                      size: 18,
                    ),
                    title: const Text(
                      'Read Tafseer',
                      style: TextStyle(
                        fontSize: AppSpacing.size12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showTafseerBottomSheet(
                        context,
                        surahName: surahName,
                        surahNumber: surahNumber,
                        ayahNumber: verseNumber,
                      );
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: const Icon(
                      LucideIcons.bookmark,
                      color: AppColors.emerald600,
                      size: 18,
                    ),
                    title: const Text(
                      'Bookmark Verse',
                      style: TextStyle(
                        fontSize: AppSpacing.size12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final note = await showBookmarkDialog(
                        context,
                        title: 'Bookmark Verse',
                        subtitle: 'Surah $surahName, Verse $verseNumber',
                        isPageMode: false,
                      );
                      if (note != null) {
                        final bookmarkService = ref.read(
                          bookmarkServiceProvider,
                        );
                        await bookmarkService.addOrUpdateVerseBookmark(
                          surahId: surahNumber,
                          ayahNumber: verseNumber,
                          note: note,
                        );
                        ref.invalidate(bookmarksProvider);
                      }
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: const Icon(
                      LucideIcons.share2,
                      color: AppColors.emerald600,
                      size: 18,
                    ),
                    title: const Text(
                      'Share Verse',
                      style: TextStyle(
                        fontSize: AppSpacing.size12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final translation = quran.getVerseTranslation(
                        surahNumber,
                        verseNumber,
                      );
                      final shareText =
                          '$arabicText\n\n"$translation"\n— Surah $surahName ($surahNumber:$verseNumber)';
                      await SharePlus.instance.share(
                        ShareParams(text: shareText, subject: 'Quran Verse'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final playingAyah = ref.watch(currentPlayingAyahProvider);
    final isHighlightEnabled = ref.watch(highlightActiveVerseProvider);
    final selectedSurah = ref.watch(selectedSurahProvider);
    final isTajweed = ref.watch(isTajweedEnabledProvider);

    List<HighlightVerse> highlights = [];
    if (playingAyah != null &&
        isHighlightEnabled &&
        selectedSurah != null &&
        playingAyah.surah == selectedSurah.number) {
      highlights = [
        HighlightVerse(
          surah: playingAyah.surah,
          verseNumber: playingAyah.ayah,
          page: playingAyah.page,
          color: isDarkMode
              ? AppColors.emerald600.withAlpha(80)
              : AppColors.emerald100,
        ),
      ];

      // Auto page-turning when playing ayah on a different page
      final targetPage = playingAyah.page;
      if (widget.controller.hasClients) {
        final currentPage =
            (widget.controller.page?.round() ?? widget.controller.initialPage) +
            1;
        if (currentPage != targetPage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && widget.controller.hasClients) {
              widget.controller.animateToPage(
                targetPage - 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              );
            }
          });
        }
      }
    } else {
      highlights = [];
    }

    return QuranPageView(
      pageController: widget.controller,
      highlights: highlights,
      isDarkMode: isDarkMode,
      isTajweed: isTajweed,
      onPageChanged: (pageNumber) {
        _handlePageSelected(pageNumber);
      },
      onLongPress: (surah, verse, details) {
        _showAyahActionBottomSheet(surahNumber: surah, verseNumber: verse);
      },
    );
  }
}
