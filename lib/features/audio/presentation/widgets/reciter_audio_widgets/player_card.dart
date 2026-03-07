import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/features/audio/presentation/state/audio_providers.dart';
import 'package:quran_app/features/audio/presentation/widgets/reciter_audio_widgets/player_card_buttons.dart';

import '../../../../../core/constants/app_colors.dart';






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

    if (selectedAudioSurah == null) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text("Select a Surah to play")),
      );
    }

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
                      selectedAudioSurah.nameEnglish,
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
                          final repeat = ref.read(repeatModeProvider.notifier);
                          repeat.state = !repeat.state;
                        },
                        icon: Icon(
                          LucideIcons.repeat,
                          color: ref.watch(repeatModeProvider) ? Colors.green : Colors.white,
                        ),
                      ),

                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                            LucideIcons.skipBack,
                        ),
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
                          onPressed: () {
                            final audioProvider = ref.read(audioServiceProvider);
                            if (playerState?.playing ?? false) {
                              audioProvider.pause();
                            } else {
                              audioProvider.play();
                            }
                          },
                        ),
                      ),

                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          LucideIcons.skipForward,
                        ),
                      ),

                      IconButton(
                        onPressed: () {},
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
                          LucideIcons.volume2,
                          color: AppColors.gray400,
                         size: 25,
                       ),
                      Expanded(
                        child: Slider(
                          value: 70,
                          max: 100,
                          onChanged: (value) {},
                        ),
                      ),
                      const Text(
                        "70%",
                        style: TextStyle(color: Colors.grey),
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
