import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/core/widgets/Loading.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/widgets/read_quran_screen_widgets/Surah_tile.dart';
import '../../../../../core/constants/app_colors.dart';
import '../ayah_details_widget/non_paged/mode_switcher.dart';

class SurahList extends ConsumerWidget {
  const SurahList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahAsync = ref.watch(surahListProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final textTheme = Theme.of(context).textTheme;

    return surahAsync.when(
      loading: () => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: LoadingWidget(),
        ),
      ),

      error: (err, stack) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(child: Text('Error: $err')),
        ),
      ),


      data: (surahs) {
        final filteredSurahs = surahs.where((s) {
          final query = searchQuery.toLowerCase();
          return s.nameArabic.toLowerCase().contains(query) ||
              s.nameEnglish.toLowerCase().contains(query);
        }).toList();

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ALL SURAHS",
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.gray700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    ModeSwitcher(
                      mode: ref.watch(readingModeProvider),
                      onChanged: (newMode) =>
                      ref.read(readingModeProvider.notifier).state = newMode,
                    ),
                  ],
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: SurahTile(surah: filteredSurahs[index]),
                  );
                },
                childCount: filteredSurahs.length,
              ),
            ),
          ],
        );
      },
    );
  }
}
