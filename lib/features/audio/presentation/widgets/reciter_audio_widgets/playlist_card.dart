import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../quran/domain/models/surah.dart';
import '../../../../quran/presentation/state/quran_providers.dart';
import '../../state/audio_providers.dart';






class PlaylistCard extends ConsumerWidget {
  const PlaylistCard({
    super.key,
    required this.surahs,
  });

  final List<Surah> surahs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final selectedIndex = ref.watch(selectedSurahIndexProvider);
    final selectedReciter = ref.watch(selectedReciterProvider);
    final audioProvider = ref.read(audioServiceProvider);

    return  ListView.builder(
      shrinkWrap: true,
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        final isSelected = selectedIndex == index;

        return InkWell(
            onTap: () async {
              final reciter = ref.read(selectedReciterProvider);
              if (reciter == null) return;

              ref.read(selectedSurahIndexProvider.notifier).state = index;

              try {
                await audioProvider.playSurah(
                  reciterFolder: reciter.audioFolder,
                  surah: surah.number,
                  totalAyahs: surah.totalAyahs,
                );
              } catch (e) {
                debugPrint("Audio error: $e");
              }
            },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.gray300
                  : Colors.white,
              border: const Border(
                bottom: BorderSide(
                  color: AppColors.gray200,
                  width: 0.5,
                ),
              ),
            ),

            child: Row(
              children: [

                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.emerald600
                        : AppColors.gray200,
                    borderRadius: BorderRadius.circular(5),
                  ),

                  child: Text(
                    "${surah.number}",
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.gray900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.nameEnglish,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${surah.translation} • ${surah.totalAyahs} verses",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  surah.nameArabic,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
