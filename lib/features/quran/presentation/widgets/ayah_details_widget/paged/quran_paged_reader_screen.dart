import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/features/progress/presentation/state/profile_progress_provider.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/paged/single_paged_render.dart';
import '../../../../../../core/constants/app_colors.dart';
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

    final startPage = widget.controller.initialPage + 1;

    _preloadPages(startPage);

    Future.microtask(() async {
      final progress = ref.read(progressServiceProvider);
      ref.read(currentPageProvider.notifier).state = startPage;

      /* final pageAyahs = await loadPageAyahs(widget.initialPage);
      final firstAyah = pageAyahs.first;

      final surahsOnPage = getSurahNumbersFromPage(widget.initialPage);
      print(surahsOnPage);
      print(firstAyah.ayah); */

      progress.trackPage(startPage);
      // ref.read(currentPageProvider.notifier).state = widget
      //     .initialPage; // may need to be deleted for surah_header section to work well
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _preloadPages(int pageNumber) {
    ref.read(pageAyahsProvider(pageNumber).future);

    if (pageNumber < 604) {
      ref.read(pageAyahsProvider(pageNumber + 1).future);
    }

    if (pageNumber > 1) {
      ref.read(pageAyahsProvider(pageNumber - 1).future);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.controller,
      reverse: true,
      itemCount: 604,
      onPageChanged: (index) async {
        final progress = ref.read(progressServiceProvider);

        final page = index + 1;
        ref.read(currentPageProvider.notifier).state = page;

        final prevSurahId = ref.read(currentPageSurahIdProvider);

        // Resolve once per page
        final newSurahId = await progress.resolveActiveSurah(
          mode: 'page',
          page: page,
        );

        // Only update UI if surah actually changed
        if (newSurahId != prevSurahId) {
          await progress.clearLastRead();
          ref.read(currentPageSurahIdProvider.notifier).state = newSurahId;
        }

        /* final pageAyahs = await loadPageAyahs(page);
        final firstAyah = pageAyahs.first;

        final surahsOnPage = getSurahNumbersFromPage(page);
        print(surahsOnPage);
        print(firstAyah.ayah); */

        progress.trackPage(page);
      },
      itemBuilder: (context, index) {
        final pageNumber = index + 1;

        final pageAyahs = ref.watch(pageAyahsProvider(pageNumber));

        return pageAyahs.when(
          loading: () => const Center(child: CircularProgressIndicator()),

          error: (e, _) => Center(child: Text(e.toString())),

          data: (ayahs) {
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: QuranPage(
                      svgAsset:
                          "assets/quran/hafs/${pageNumber.toString().padLeft(3, '0')}.svg",
                      ayahs: ayahs,
                      onTapAyah: (ayah) {
                        ref
                            .read(currentPlayingAyahProvider.notifier)
                            .state = AyahIdentifier(
                          surah: ayah.surah,
                          ayah: ayah.ayah,
                          page: ayah.page,
                        );
                      },
                    ),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: Divider(color: AppColors.gray400, thickness: 1),
                    ),

                    Container(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        ayahs.first.page.toString(),
                        style: TextStyle(
                          fontSize: AppSpacing.size10,
                          color: AppColors.gray600,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Divider(color: AppColors.gray400, thickness: 1),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
