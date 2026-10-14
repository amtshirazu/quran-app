import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
import 'package:quran_app/features/progress/presentation/state/last_read_provider.dart';
import 'package:quran_app/features/progress/presentation/state/profile_progress_provider.dart';

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

      final startPage = widget.controller.hasClients && widget.controller.page != null
          ? widget.controller.page!.round() + 1
          : widget.controller.initialPage + 1;

      _handlePageSelected(startPage);
    });
  }

  Future<void> _handlePageSelected(int pageNumber) async {
    ref.read(currentPageProvider.notifier).state = pageNumber;

    final progress = ref.read(progressServiceProvider);
    final surahId = await progress.resolveActiveSurah(
      mode: 'page',
      page: pageNumber,
    );

    if (surahId != null) {
      ref.read(currentPageSurahIdProvider.notifier).state = surahId;
    }

    // 1. Instantly register place-marker so Continue Reading works immediately
    await progress.setBookmarkImmediate(
      mode: 'page',
      page: pageNumber,
      surahId: surahId,
    );

    _invalidateProgressProviders();

    // 2. Start the 30-second dwell countdown for reading credit and streak
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

  @override
  void dispose() {
    _dwellTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return QuranPageView(
      pageController: widget.controller,
      highlights: const [],
      isDarkMode: isDarkMode,
      isTajweed: false,
      onPageChanged: (pageNumber) {
        _handlePageSelected(pageNumber);
      },
      onLongPress: (surah, verse, details) {
        debugPrint("Long pressed: Surah $surah, Verse $verse, Details: $details");
      },
    );
  }
}