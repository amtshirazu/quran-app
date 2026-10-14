import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/progress/presentation/state/last_read_provider.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/non_paged/surah_header_section.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/paged/bottom_page_indicator.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/paged/paged_surah_map.dart';
import '../state/reading_mode.dart';
import '../widgets/ayah_details_widget/non_paged/ayah_list.dart';
import '../widgets/ayah_details_widget/non_paged/basmallah.dart';
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
  int? _currentSurahNumber;

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  void _checkAndInitialize(int surahNumber) {
    if (_currentSurahNumber == surahNumber) return;
    _currentSurahNumber = surahNumber;
    _ayahKeys.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final range = surahPageRanges[surahNumber];
      int initialPage = range?.start ?? 1;

      // 1. Check bookmark / jump target
      final jumpPage = ref.read(jumpToPageProvider);
      final jumpAyah = ref.read(targetAyahProvider);

      if (jumpAyah != null) {
        _targetAyah = jumpAyah;
        ref.read(targetAyahProvider.notifier).state = null;
      }

      if (jumpPage != null) {
        initialPage = jumpPage;
        ref.read(jumpToPageProvider.notifier).state = null;
      } else {
        // 2. Check resume target
        final shouldResume = ref.read(shouldResumeLastReadProvider);
        if (shouldResume) {
          final lastRead = ref.read(lastReadProvider).asData?.value;
          if (lastRead != null) {
            final mode = lastRead['mode'];
            if (mode == 'ayah' && lastRead['surah_id'] == surahNumber) {
              _targetAyah = lastRead['ayah'];
            } else if (mode == 'page' && lastRead['page'] is int) {
              initialPage = lastRead['page'];
            }
          }
        }
        ref.read(shouldResumeLastReadProvider.notifier).state = false;
      }

      _pageController?.dispose();
      _pageController = PageController(initialPage: initialPage - 1);

      if (mounted) setState(() {});
    });
  }

  /// Progressive convergence jump: accurately brings lazily-built Ayahs into view
  void _scrollToAyah(int ayah, {int attempts = 0}) {
    if (!mounted || attempts > 40) return;

    final key = _ayahKeys[ayah];

    // 1. If target Ayah widget is in context, align it perfectly at top!
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 250),
        curve: Curves.fastOutSlowIn,
        alignment: 0.0,
      );
      return;
    }

    // 2. If target Ayah is not yet in context, step scroll position downwards to expand layout
    if (_scrollController.hasClients) {
      final selectedSurah = ref.read(selectedSurahProvider);
      final hasBasmallah = selectedSurah != null &&
          selectedSurah.number != 1 &&
          selectedSurah.number != 9;

      final headerOffset = 380.0 + (hasBasmallah ? 80.0 : 0.0);
      final estimatedOffset = headerOffset + ((ayah - 1) * 260.0);
      final maxScroll = _scrollController.position.maxScrollExtent;

      if (attempts == 0) {
        final initialTarget = estimatedOffset.clamp(0.0, maxScroll);
        _scrollController.jumpTo(initialTarget);
      } else {
        // Step forward by 800px per frame until target Ayah widget is generated in context
        final nextTarget = (_scrollController.offset + 800.0).clamp(0.0, maxScroll);
        if ((_scrollController.offset - nextTarget).abs() > 1.0) {
          _scrollController.jumpTo(nextTarget);
        }
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToAyah(ayah, attempts: attempts + 1);
        }
      });
    }
  }

  void _onAyahListBuilt() {
    if (_targetAyah != null) {
      final ayah = _targetAyah!;
      _targetAyah = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToAyah(ayah);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedSurah = ref.watch(selectedSurahProvider);

    if (selectedSurah == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    _checkAndInitialize(selectedSurah.number);

    final readingMode = ref.watch(readingModeProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(85),
        child: SurahHeaderSection(
          controller: _pageController,
          mode: readingMode,
        ),
      ),
      body: readingMode == ReadingMode.translation
          ? Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                const SliverToBoxAdapter(child: SurahInfo()),

                if (selectedSurah.number != 1 &&
                    selectedSurah.number != 9)
                  const SliverToBoxAdapter(child: Basmallah()),

                const SliverToBoxAdapter(child: SizedBox(height: 10)),

                AyahList(
                  ayahkeys: _ayahKeys,
                  onListBuilt: _onAyahListBuilt,
                ),

                const SurahNavigationCard(),
              ],
            ),
          ),
        ],
      )
          : Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: _pageController == null
                ? const Center(child: CircularProgressIndicator())
                : QuranPagedReaderScreen(controller: _pageController!),
          ),
          const BottomPageIndicator(),
        ],
      ),
    );
  }
}
