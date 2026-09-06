import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/features/azkaar_and_dua/domain/model/quranic_dua.dart';
import 'package:quran_app/features/azkaar_and_dua/presentation/states/dua_provider.dart';
import 'package:quran_app/features/quran/domain/models/surah.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/state/reading_mode.dart';
import 'package:quran_app/features/quran/presentation/widgets/read_quran_screen_widgets/surah_verse_number_badge.dart';
import 'package:quran_app/features/quran/presentation/widgets/read_quran_screen_widgets/surah_verses_badge.dart';
import '../../domain/model/search_result.dart';
import '../state/search_provider.dart';
import 'highlighted_text.dart';

class SearchResultsView extends ConsumerWidget {
  final UnifiedSearchResults results;

  const SearchResultsView({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(searchTabFilterProvider);

    if (results.totalCount == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.searchX,
                size: 48,
                color: AppColors.gray400,
              ),
              const SizedBox(height: 16),
              Text(
                'No matching results found for "${results.query}"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try searching with a different surah, keyword, or topic.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    switch (activeTab) {
      case SearchTab.ayah:
        return _buildAyahsList(context, ref, results.ayahs, results.query);
      case SearchTab.surah:
        return _buildSurahsList(context, ref, results.surahs, results.query);
      case SearchTab.azkaar:
        return _buildAzkaarList(context, ref, results.azkaar, results.query);
      case SearchTab.dua:
        return _buildDuasList(context, ref, results.duas, results.query);
      case SearchTab.all:
        return _buildAllList(context, ref);
    }
  }

  Widget _buildAllList(BuildContext context, WidgetRef ref) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        /// 1. Ayahs Section
        if (results.ayahs.isNotEmpty) ...[
          _buildSectionHeader('Ayahs (${results.ayahs.length})'),
          ...results.ayahs.take(5).map(
                (item) => _buildAyahCard(context, ref, item, results.query),
              ),
          const SizedBox(height: 16),
        ],

        /// 2. Surahs Section
        if (results.surahs.isNotEmpty) ...[
          _buildSectionHeader('Surahs (${results.surahs.length})'),
          ...results.surahs.map(
                (surah) => _buildSurahCard(context, ref, surah, results.query),
              ),
          const SizedBox(height: 16),
        ],

        /// 3. Azkaar Section
        if (results.azkaar.isNotEmpty) ...[
          _buildSectionHeader('Azkaar (${results.azkaar.length})'),
          ...results.azkaar.take(5).map(
                (item) => _buildAzkarCard(context, ref, item, results.query),
              ),
          const SizedBox(height: 16),
        ],

        /// 4. Duas Section
        if (results.duas.isNotEmpty) ...[
          _buildSectionHeader('Duas (${results.duas.length})'),
          ...results.duas.take(5).map(
                (dua) => _buildDuaCard(context, ref, dua, results.query),
              ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildAyahsList(
    BuildContext context,
    WidgetRef ref,
    List<AyahSearchResult> ayahs,
    String query,
  ) {
    if (ayahs.isEmpty) return _buildEmptyScopedState('Ayahs');

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: ayahs.length,
      itemBuilder: (context, index) {
        return _buildAyahCard(context, ref, ayahs[index], query);
      },
    );
  }

  Widget _buildSurahsList(
    BuildContext context,
    WidgetRef ref,
    List<Surah> surahs,
    String query,
  ) {
    if (surahs.isEmpty) return _buildEmptyScopedState('Surahs');

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        return _buildSurahCard(context, ref, surahs[index], query);
      },
    );
  }

  Widget _buildAzkaarList(
    BuildContext context,
    WidgetRef ref,
    List<AzkarSearchResult> azkaar,
    String query,
  ) {
    if (azkaar.isEmpty) return _buildEmptyScopedState('Azkaar');

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: azkaar.length,
      itemBuilder: (context, index) {
        return _buildAzkarCard(context, ref, azkaar[index], query);
      },
    );
  }

  Widget _buildDuasList(
    BuildContext context,
    WidgetRef ref,
    List<QuranicDua> duas,
    String query,
  ) {
    if (duas.isEmpty) return _buildEmptyScopedState('Duas');

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: duas.length,
      itemBuilder: (context, index) {
        return _buildDuaCard(context, ref, duas[index], query);
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2421),
        ),
      ),
    );
  }

  Widget _buildEmptyScopedState(String categoryName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: Text(
          'No matching $categoryName found.',
          style: const TextStyle(
            color: AppColors.gray500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAyahCard(
    BuildContext context,
    WidgetRef ref,
    AyahSearchResult item,
    String query,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final surahs = ref.read(surahListProvider).value;
          final surah = surahs?.firstWhere(
            (s) => s.number == item.surahNum,
            orElse: () => surahs.first,
          );
          if (surah != null) {
            ref.read(readingModeProvider.notifier).state =
                ReadingMode.translation;
            ref.read(selectedSurahProvider.notifier).state = surah;
            ref.read(targetAyahProvider.notifier).state = item.ayahNum;
            ref.read(shouldResumeLastReadProvider.notifier).state = false;
            context.push('/readAyah');
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Arabic Verse Text
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                item.arabicText,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'Uthmanic',
                  fontSize: 22,
                  height: 1.8,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
            ),
            const SizedBox(height: 12),

            /// Highlighted English Translation
            HighlightedText(
              text: item.translationText,
              query: query,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 12),

            /// Reference Line
            Row(
              children: [
                const Icon(
                  LucideIcons.bookOpen,
                  size: 16,
                  color: AppColors.emerald600,
                ),
                const SizedBox(width: 6),
                Text(
                  '${item.surahName} ${item.surahNum}:${item.ayahNum}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.emerald600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahCard(
    BuildContext context,
    WidgetRef ref,
    Surah surah,
    String query,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ref.read(selectedSurahProvider.notifier).state = surah;
              ref.read(shouldResumeLastReadProvider.notifier).state = false;
              context.push('/readAyah');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  SurahVerseNumberBadge(surahNumber: surah.number),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HighlightedText(
                          text: surah.nameEnglish,
                          query: query,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        HighlightedText(
                          text: surah.translation,
                          query: query,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        surah.nameArabic,
                        style: const TextStyle(
                          fontFamily: 'Uthmanic',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SurahVersesBadge(totalAyahs: surah.totalAyahs),
                          const SizedBox(width: 4),
                          const Icon(
                            LucideIcons.chevronRight,
                            size: 16,
                            color: AppColors.gray400,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAzkarCard(
    BuildContext context,
    WidgetRef ref,
    AzkarSearchResult item,
    String query,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.emerald100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            LucideIcons.sun,
            color: AppColors.emerald600,
            size: 20,
          ),
        ),
        title: HighlightedText(
          text: item.chapter.name,
          query: query,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.gray900,
          ),
        ),
        subtitle: Text(
          item.category.name,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.gray500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.gray400,
        ),
        onTap: () {
          context.push('/azkaarChapters', extra: item.category);
        },
      ),
    );
  }

  Widget _buildDuaCard(
    BuildContext context,
    WidgetRef ref,
    QuranicDua dua,
    String query,
  ) {
    final isWitr = dua.categoryType == 'witr';
    final formattedSubject = isWitr
        ? 'Qunoot & Supplication'
        : (dua.subject.isNotEmpty
            ? '${dua.subject[0].toUpperCase()}${dua.subject.substring(1)}'
            : 'General');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ref.read(selectedDuaCategoryProvider.notifier).state =
              isWitr ? DuaCategory.witr : DuaCategory.quranic;
          ref.read(targetDuaIdProvider.notifier).state = dua.id;
          context.push('/duas');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HighlightedText(
                        text: formattedSubject,
                        query: query,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.emerald100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isWitr ? "Witr & Qunoot" : "Quran",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.emerald600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: "${dua.arabic}\n\n${dua.translation}",
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Dua copied to clipboard"),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(
                        LucideIcons.copy,
                        size: 20,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            /// Arabic text
            Text(
              dua.arabic,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: "Uthmanic",
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.8,
              ),
            ),
            const SizedBox(height: 12),

            /// Transliteration
            if (dua.transliteration != null &&
                dua.transliteration!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9F8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dua.transliteration!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            /// Translation with Query Highlighting
            HighlightedText(
              text: dua.translation,
              query: query,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            /// Reference / Source
            Text(
              isWitr
                  ? (dua.source ?? "Hadith / Sunnah")
                  : "Quran ${dua.surahNum}:${dua.ayahNum}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.emerald600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
