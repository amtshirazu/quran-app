import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/features/audio/presentation/state/audio_providers.dart';
import 'package:quran_app/features/audio/presentation/state/repeat_states.dart';
import 'package:quran_app/features/audio/presentation/widgets/reciter_audio_widgets/player_card_buttons.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../quran/presentation/state/quran_providers.dart';






class PlayerCard extends ConsumerStatefulWidget {
  const PlayerCard({super.key});

  @override
  ConsumerState<PlayerCard> createState() => PlayerCardState();
}

class PlayerCardState extends ConsumerState<PlayerCard> {

  @override
  Widget build(BuildContext context) {

    final selectedAudioSurah = ref.watch(selectedAudioSurahProvider);
    final playerState = ref.watch(audioStreamProvider).value;



    return Card(
        margin: EdgeInsets.symmetric(horizontal: 15),
        clipBehavior: Clip.antiAlias,

        child: Column(
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.emerald200,
                    AppColors.emerald300,
                    AppColors.emerald200,
                  ],
                ),
              ),

              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      selectedAudioSurah!.nameEnglish,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),

                   Text(
                        selectedAudioSurah.nameArabic,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 40,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Chip(label: Text(selectedAudioSurah.translation)),
                    const SizedBox(height: 6),
                    Text(
                      "Surah ${selectedAudioSurah.number} • ${selectedAudioSurah.totalAyahs} Verses",
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  Column(
                    children: [
                      Slider(
                        value: 20,
                        max: 100,
                        onChanged: (value) {},
                      ),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("0:20",
                              style: TextStyle(color: Colors.grey)),
                          Text("4:25",
                              style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      IconButton(
                        onPressed: () {
                          final repeatNotifier = ref.read(repeatModeProvider.notifier);

                          final newMode = switch(repeatNotifier.state) {
                            RepeatStates.off => RepeatStates.repeatAll,
                            RepeatStates.repeatAll => RepeatStates.repeatOne,
                            RepeatStates.repeatOne => RepeatStates.off,
                          };

                          repeatNotifier.state = newMode;
                        },
                        icon: Icon(
                            switch(ref.watch(repeatModeProvider)){
                              RepeatStates.off => LucideIcons.repeat,
                              RepeatStates.repeatAll => LucideIcons.repeat,
                              RepeatStates.repeatOne => LucideIcons.repeat1,
                            },
                          color: switch(ref.watch(repeatModeProvider)){
                            RepeatStates.off => AppColors.gray600,
                            RepeatStates.repeatAll => Colors.green,
                            RepeatStates.repeatOne => Colors.green,
                          }
                        ),
                      ),

                      IconButton(
                        onPressed: () async {
                          final audio = ref.read(audioServiceProvider);
                          final reciter = ref.read(selectedReciterProvider);
                          final surahs = ref.read(surahListProvider).value;

                          if (reciter == null) return;

                          final currentIndex = ref.read(selectedSurahIndexProvider) ?? 0;

                          if (currentIndex > 0) {
                            final prevIndex = currentIndex - 1;

                            ref.read(selectedSurahIndexProvider.notifier).state = prevIndex;

                            final surah = surahs![prevIndex];

                            await audio.playSurah(
                              reciterFolder: reciter.audioFolder,
                              surah: surah.number,
                              totalAyahs: surah.totalAyahs,
                            );
                          }
                        },
                        icon: const Icon(LucideIcons.skipBack),
                      ),

                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.emerald600,
                        ),
                        child: IconButton(
                          icon: Icon(
                            playerState?.playing == true ? LucideIcons.pause : LucideIcons.play,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                              final audio = ref.read(audioServiceProvider);
                              final reciter = ref.read(selectedReciterProvider);
                              final surah = ref.read(selectedAudioSurahProvider);

                              if (playerState?.playing == true) {
                                await audio.pause();
                              } else {

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
                        ),
                      ),

                      IconButton(
                        onPressed: () async {
                          final audio = ref.read(audioServiceProvider);
                          final reciter = ref.read(selectedReciterProvider);
                          final surahs = ref.read(surahListProvider).value;

                          if (reciter == null) return;

                          final currentIndex = ref.read(selectedSurahIndexProvider) ?? 0;

                          if (currentIndex < surahs!.length - 1) {
                            final nextIndex = currentIndex + 1;

                            ref.read(selectedSurahIndexProvider.notifier).state = nextIndex;

                            final surah = surahs[nextIndex];

                            await audio.playSurah(
                              reciterFolder: reciter.audioFolder,
                              surah: surah.number,
                              totalAyahs: surah.totalAyahs,
                            );
                          }
                        },
                        icon: const Icon(LucideIcons.skipForward),
                      ),

                      IconButton(
                        onPressed: () {
                          final volumeNotifier = ref.read(volumeProvider.notifier);
                          final audio = ref.read(audioServiceProvider);

                          final newVolume = (volumeNotifier.state + 0.05).clamp(0.0, 1.0);

                          volumeNotifier.state = newVolume;

                          audio.setVolume(newVolume);
                        },
                        icon:  Icon(
                            LucideIcons.volume2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),


                  Row(
                    children: [
                      Icon(
                        ref.watch(volumeProvider) == 0
                            ? LucideIcons.volumeX :
                        ref.watch(volumeProvider) <= 0.5
                            ? LucideIcons.volume1 : LucideIcons.volume2,
                        color: AppColors.gray400,
                        size: 25,
                      ),
                      Expanded(
                        child: Slider(
                          value: ref.watch(volumeProvider),
                          max: 1,
                          onChanged: (value) {
                            ref.read(volumeProvider.notifier).state = value;
                            ref.read(audioServiceProvider).setVolume(value);
                          },
                        ),
                      ),
                      Text(
                          "${(ref.watch(volumeProvider) * 100).toInt()}%",
                        style: const TextStyle(color: Colors.grey),
                      )
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: PlayerCardButtons(
                          icon: LucideIcons.share,
                          text: "Share",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PlayerCardButtons(
                          icon: LucideIcons.download,
                          text: "Download",
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      );
  }
}
