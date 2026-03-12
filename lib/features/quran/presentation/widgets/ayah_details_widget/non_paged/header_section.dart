import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/features/quran/presentation/widgets/read_quran_screen_widgets/search.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../audio/presentation/state/audio_providers.dart';
import '../../../state/quran_providers.dart';

class AyahHeaderSection extends ConsumerWidget {
  const AyahHeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahMetadata = ref.watch(selectedSurahProvider);
    final textTheme = Theme.of(context).textTheme;
    final audio = ref.read(audioServiceProvider);
    final playerState = ref.watch(audioStreamProvider).value;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      decoration: const BoxDecoration(color: AppColors.emerald600),

      child: Row(
        children: [
          IconButton(
            onPressed: () {
              audio.reset();
              context.go("/surahs");
            },
            icon: Icon(LucideIcons.arrowLeft, color: Colors.white, size: 32),
          ),
          SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                surahMetadata?.nameEnglish ?? "",
                style: textTheme.titleLarge,
              ),

              Text(
                surahMetadata?.translation ?? "",
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),

          Spacer(),

          IconButton(
            onPressed: () async {
              final reciter = ref.read(defaultReciterProvider);
              final surahs = ref.read(surahListProvider).value;
              final selectedSurah = ref.read(selectedSurahProvider);

              if (playerState?.playing == true) {
                await audio.pause();
              } else {

                final surah = surahs?[selectedSurah!.number - 1];

                if (!audio.hasLoadedSurah && reciter != null && surah != null) {
                  await audio.playSurah(
                    reciterFolder: reciter.audioFolder,
                    surah: surah.number,
                    totalAyahs: surah.totalAyahs,
                  );
                  return;
                }

                if (playerState?.processingState == ProcessingState.completed) {
                  await audio.seekToStart();
                }
                await audio.play();
              }

            },
            icon: Icon(
                playerState?.playing == true ? LucideIcons.pause : LucideIcons.play,
                color: AppColors.gray200,
                size: 24
            ),
          ),
        ],
      ),
    );
  }
}
