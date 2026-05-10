import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
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
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final startPage = widget.controller.initialPage + 1;

      final progress = ref.read(progressServiceProvider);

      await progress.updateStreak();

      ref.read(currentPageProvider.notifier).state = startPage;

      progress.trackPage(startPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    //final currentPage = ref.watch(currentPageProvider);

    return QuranPageView(
      pageController: widget.controller,

      highlights: const [],

      isDarkMode: isDarkMode,

      isTajweed: false,

      onPageChanged: (pageNumber) async {
        final progress = ref.read(progressServiceProvider);

        ref.read(currentPageProvider.notifier).state = pageNumber;

        final prevSurahId = ref.read(currentPageSurahIdProvider);

        final newSurahId = await progress.resolveActiveSurah(
          mode: 'page',
          page: pageNumber,
        );

        if (newSurahId != prevSurahId) {
          await progress.clearLastRead();

          ref.read(currentPageSurahIdProvider.notifier).state = newSurahId;
        }

        progress.trackPage(pageNumber);
      },

      onLongPress: (surah, verse, details) {
        debugPrint(
          "Long pressed: Surah $surah, Verse $verse - Details: $details",
        );
      },
    );
  }
}
