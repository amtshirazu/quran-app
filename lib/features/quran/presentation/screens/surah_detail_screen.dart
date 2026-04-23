import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/non_paged/header_section.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../progress/presentation/state/progress_provider.dart';
import '../state/reading_mode.dart';
import '../widgets/ayah_details_widget/non_paged/ayah_list.dart';
import '../widgets/ayah_details_widget/non_paged/basmallah.dart';
import '../widgets/ayah_details_widget/paged/paged_surah_map.dart';
import '../widgets/ayah_details_widget/paged/quran_paged_reader_screen.dart';
import '../widgets/ayah_details_widget/non_paged/surah_navigation_card.dart';
import '../widgets/ayah_details_widget/non_paged/surah_info.dart';

class SurahDetailScreen extends ConsumerStatefulWidget {
  const SurahDetailScreen({super.key});

  @override
  ConsumerState<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends ConsumerState<SurahDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};

  PageController? _pageController;
  int? _targetAyah;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final selectedSurah = ref.read(selectedSurahProvider);
      if (selectedSurah == null) return;

      final progressService = ref.read(progressServiceProvider);
      final lastRead = await progressService.getLastRead();

      final range = surahPageRanges[selectedSurah.number];
      var initialPage = (range?.start ?? 1) - 1;

      if (lastRead != null && lastRead['surah_id'] == selectedSurah.number) {
        final mode = lastRead['mode'];

        if (mode == 'ayah') {
          _targetAyah = lastRead['ayah'];
        } else if (mode == 'page' && lastRead['page'] is int) {
          initialPage = (lastRead['page'] as int) - 1;
        }
      }

      _pageController = PageController(initialPage: initialPage);

      if (mounted) {
        setState(() {});
      }
    });
  }

  void _scrollToAyah(int ayah) {
    if (!mounted) return;

    final key = _ayahKeys[ayah];

    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 50),
        curve: Curves.fastOutSlowIn,
        alignment: 0.1,
      );
    } else {
      _scrollController
          .animateTo(
            _scrollController.offset + 100,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          )
          .then((_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToAyah(ayah);
            });
          });
    }
  }

  void _jumpToPage(int? page) {
    if (page == null || _pageController == null) return;

    _pageController!.jumpToPage(page - 1);
  }

  void _onAyahListBuilt() {
    if (_targetAyah != null) {
      _scrollToAyah(_targetAyah!);
      _targetAyah = null;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readingMode = ref.watch(readingModeProvider);
    final selectedSurah = ref.watch(selectedSurahProvider);

    if (selectedSurah == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.emerald50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            AyahHeaderSection(),

            if (readingMode == ReadingMode.translation)
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(child: SurahInfo()),

                    if (selectedSurah.number != 1 && selectedSurah.number != 9)
                      SliverToBoxAdapter(child: Basmallah()),

                    const SliverToBoxAdapter(child: SizedBox(height: 10)),

                    AyahList(
                      ayahkeys: _ayahKeys,
                      onListBuilt: _onAyahListBuilt,
                    ),

                    SurahNavigationCard(),
                  ],
                ),
              )
            else
              Expanded(
                child: _pageController == null
                    ? const Center(child: CircularProgressIndicator())
                    : QuranPagedReaderScreen(
                        controller: _pageController!,
                        initialPage:
                            (surahPageRanges[selectedSurah.number]?.start ?? 1),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
