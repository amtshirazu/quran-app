import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/widgets/read_quran_screen_widgets/surah_of_the_day.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/models/surah.dart';
import 'quick_acces_tile.dart';


class QuickAccess extends ConsumerWidget {
  const QuickAccess({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final lastRead = ref.watch(selectedSurahProvider);
    final surahListAsync = ref.watch(surahListProvider);

    Surah? surahOftheDay;

    if(surahListAsync is AsyncData<List<Surah>>){
      final surahList = surahListAsync.value;
      surahOftheDay = getSurahOfTheDay(surahList);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Access",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: QuickAccessCard(
                  bgColor: AppColors.emerald100,
                  fgColor: AppColors.emerald600,
                  icon: LucideIcons.book,
                  label: "Last Read",
                  sublabel: lastRead == null ? "Al-Baqara" : lastRead.nameEnglish,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: QuickAccessCard(
                  bgColor: AppColors.blue100,
                  fgColor: AppColors.blue600,
                  icon: LucideIcons.bookOpen,
                  label: "Today",
                  sublabel: surahOftheDay?.nameEnglish ?? "Al-Kahf",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}