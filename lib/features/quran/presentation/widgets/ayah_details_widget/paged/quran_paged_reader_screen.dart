import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/paged/single_paged_render.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/paged/paged_surah_map.dart';
import '../../../../../audio/presentation/state/audio_providers.dart';
import '../../../state/quran_providers.dart';

class QuranPagedReaderScreen extends ConsumerStatefulWidget {
  final int initialPage;

  const QuranPagedReaderScreen({super.key, required this.initialPage});

  @override
  ConsumerState<QuranPagedReaderScreen> createState() =>
      _QuranPagedReaderScreenState();
}

class _QuranPagedReaderScreenState
    extends ConsumerState<QuranPagedReaderScreen> {
  late PageController controller = PageController();

  @override
  void initState() {
    super.initState();

    controller = PageController(initialPage: widget.initialPage - 1);

    controller.addListener(() {
      final currentPage = (controller.page?.round() ?? 0) + 1;

      _preloadPages(currentPage);

      final surahNumber = getSurahNumberFromPage(currentPage);
      final currentSelected = ref.read(selectedSurahProvider);

      if (currentSelected?.number != surahNumber) {
        final surahList = ref.read(surahListProvider).value;
        if (surahList != null) {
          final newSurah = surahList.firstWhere((s) => s.number == surahNumber);
          ref.read(selectedSurahProvider.notifier).state = newSurah;
          ref.read(audioServiceProvider).reset();
        }
      }
    });
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
      controller: controller,
      reverse: true,
      itemCount: 604,
      itemBuilder: (context, index) {
        final pageNumber = index + 1;

        final pageAyahs = ref.watch(pageAyahsProvider(pageNumber));

        return pageAyahs.when(
          loading: () => const Center(child: CircularProgressIndicator()),

          error: (e, _) => Center(child: Text(e.toString())),

          data: (ayahs) {
            return QuranPage(
              svgAsset:
                  "lib/assets/quran/hafs/${pageNumber.toString().padLeft(3, '0')}.svg",
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
            );
          },
        );
      },
    );
  }
}
