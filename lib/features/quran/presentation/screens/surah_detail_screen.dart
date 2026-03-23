import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/widgets/ayah_details_widget/non_paged/header_section.dart';
import '../../../../core/constants/app_colors.dart';
import '../state/reading_mode.dart';
import '../widgets/ayah_details_widget/non_paged/ayah_list.dart';
import '../widgets/ayah_details_widget/non_paged/basmallah.dart';
import '../widgets/read_quran_screen_widgets/mode_switcher.dart';
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
                  slivers: [
                    SliverToBoxAdapter(child: SurahInfo()),
                    if(selectedSurah.number != 1 && selectedSurah.number != 9)
                    SliverToBoxAdapter(
                        child: Basmallah()
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 10)),
                    AyahList(),
                    SurahNavigationCard(),
                  ],
                ),
              )
            else
              Expanded(
                child: QuranPagedReaderScreen(
                  initialPage: surahStartPage[selectedSurah.number]!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
