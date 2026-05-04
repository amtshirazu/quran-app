import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:quran_app/core/database/database_helper.dart';
import 'package:quran_app/features/progress/presentation/state/last_read_provider.dart';
import 'package:quran_app/features/progress/presentation/state/profile_progress_provider.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/non_paged/surah_header_section.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/paged/paged_surah_map.dart';
import '../../../../core/constants/app_colors.dart';
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

  int? _currentSurahForKeys;
  bool _initialized = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  void _initOnce() {
    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final progress = ref.read(progressServiceProvider);
      // ONE unified streak trigger
      await progress.updateStreak();

      // final dbHelper = DatabaseHelper.instance;
      // final db = await dbHelper.database;
      // final result = await db.query('streak', limit: 1);
      // print(result);

      final selectedSurah = ref.read(selectedSurahProvider);
      if (selectedSurah == null) return;

      _resetKeysIfNeeded(selectedSurah.number);

      final range = surahPageRanges[selectedSurah.number];
      int initialPage = range?.start ?? 1;

      /// 🔥 1. BOOKMARK JUMP (highest priority)
      final jumpPage = ref.read(jumpToPageProvider);
      if (jumpPage != null) {
        initialPage = jumpPage;
        ref.read(jumpToPageProvider.notifier).state = null;
      } else {
        /// 🔥 2. LAST READ ONLY IF NO JUMP
        final shouldResume = ref.read(shouldResumeLastReadProvider);

        if (shouldResume) {
          final lastRead = ref.read(lastReadProvider).asData?.value;

          if (lastRead != null) {
            final mode = lastRead['mode'];

            if (mode == 'ayah' &&
                lastRead['surah_id'] == selectedSurah.number) {
              _targetAyah = lastRead['ayah'];
            } else if (mode == 'page' && lastRead['page'] is int) {
              initialPage = lastRead['page'];
            }
          }
        }

        ref.read(shouldResumeLastReadProvider.notifier).state = false;
      }

      /// 🔥 3. CREATE CONTROLLER SAFELY
      _pageController?.dispose();
      _pageController = PageController(initialPage: initialPage - 1);

      if (mounted) setState(() {});
    });
  }

  void _resetKeysIfNeeded(int surahNumber) {
    if (_currentSurahForKeys != surahNumber) {
      _ayahKeys.clear();
      _currentSurahForKeys = surahNumber;
    }
  }

  void _scrollToAyah(int ayah) {
    if (!mounted) return;

    final key = _ayahKeys[ayah];

    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        alignment: 0.1,
      );
    } else {
      _scrollController
          .animateTo(
            _scrollController.offset + 120,
            duration: const Duration(milliseconds: 200),
            curve: Curves.linear,
          )
          .then((_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToAyah(ayah);
            });
          });
    }
  }

  void _onAyahListBuilt() {
    if (_targetAyah != null) {
      _scrollToAyah(_targetAyah!);
      _targetAyah = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    _initOnce();

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
            SurahHeaderSection(mode: readingMode, controller: _pageController),

            if (readingMode == ReadingMode.translation)
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(child: SurahInfo()),

                    if (selectedSurah.number != 1 && selectedSurah.number != 9)
                      const SliverToBoxAdapter(child: Basmallah()),

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
                    : QuranPagedReaderScreen(controller: _pageController!),
              ),
          ],
        ),
      ),
    );
  }
}
