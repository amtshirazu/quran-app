import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_spacing.dart';
import 'package:quran_app/features/progress/presentation/state/last_read_provider.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/widgets/read_quran_screen_widgets/surah_of_the_day.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/models/surah.dart';
import 'quick_acces_tile.dart';

class QuickAccess extends ConsumerWidget {
  const QuickAccess({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultSurahOfTheDay = Surah(
      number: 18,
      nameArabic: "الكهف",
      nameEnglish: "Al-Kahf",
      totalAyahs: 110,
      translation: 'The Cave',
      revelationType: 'Meccan',
    );

    final defaultLastRead = Surah(
      number: 2,
      nameArabic: "البقرة",
      nameEnglish: "Al-Baqara",
      totalAyahs: 286,
      translation: 'The Cow',
      revelationType: 'Madinan',
    );

    final surahListAsync = ref.watch(surahListProvider);
    final lastReadSurahAsync = ref.watch(lastReadResolvedSurahProvider);

    Surah? surahOfTheDay;

    if (surahListAsync is AsyncData<List<Surah>>) {
      final surahList = surahListAsync.value;
      surahOfTheDay = getSurahOfTheDay(surahList);
    }

    final surahForLastRead = lastReadSurahAsync.when(
      data: (surah) => surah ?? defaultLastRead,
      loading: () => defaultLastRead,
      error: (_, __) => defaultLastRead,
    );

    final surahForToday = surahOfTheDay ?? defaultSurahOfTheDay;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.size16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Access",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.gray700,
              fontSize: AppSpacing.size16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: QuickAccessCard(
                  surah: surahForLastRead,
                  bgColor: AppColors.emerald100,
                  fgColor: AppColors.emerald600,
                  icon: LucideIcons.book,
                  label: "Last Read",
                  sublabel: surahForLastRead.nameEnglish,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: QuickAccessCard(
                  surah: surahForToday,
                  bgColor: AppColors.blue100,
                  fgColor: AppColors.blue600,
                  icon: LucideIcons.bookOpen,
                  label: "Today",
                  sublabel: surahForToday.nameEnglish,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
