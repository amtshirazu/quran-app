import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/audio/presentation/state/audio_providers.dart';
import 'package:quran_app/features/audio/presentation/state/repeat_states.dart';
import 'package:quran_app/features/audio/presentation/widgets/reciter_audio_widgets/player_card_buttons.dart';
import 'package:quran_app/features/settings/presentation/state/download_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../quran/presentation/state/quran_providers.dart';

class PlayerCard extends ConsumerStatefulWidget {
  const PlayerCard({super.key});

  @override
  ConsumerState<PlayerCard> createState() => PlayerCardState();
}

class PlayerCardState extends ConsumerState<PlayerCard> {
  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    final hourStamp = hours > 0 ? '$hours:' : '';
    final minStamp = minutes.toString().padLeft(2, '0');
    final secStamp = seconds.toString().padLeft(2, '0');

    return '$hourStamp$minStamp:$secStamp';
  }

  @override
  Widget build(BuildContext context) {
    final selectedAudioSurah = ref.watch(selectedAudioSurahProvider);
    final playerState = ref.watch(audioStreamProvider).value;
    final audioPlayer = ref.watch(audioServiceProvider).player;
    final reciter = ref.watch(selectedReciterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (selectedAudioSurah == null) {
      return const SizedBox.shrink();
    }

    final subtextColor = isDark ? AppTheme.darkTextSecondary : Colors.black54;
    final repeatMode = ref.watch(repeatModeProvider);
    final volume = ref.watch(volumeProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      clipBehavior: Clip.antiAlias,
      elevation: isDark ? 0 : 4,
      color: isDark ? AppTheme.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark
            ? const BorderSide(color: AppTheme.darkBorder)
            : BorderSide.none,
      ),
      child: Column(
        children: [
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: isDark
                  ? null
                  : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.deepGreen,
                  AppColors.emerald600,
                ],
              ),
              color: isDark ? const Color(0xFF162320) : null,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    selectedAudioSurah.nameEnglish,
                    style: const TextStyle(
                      fontSize: AppSpacing.size24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedAudioSurah.nameArabic,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppSpacing.size24,
                      fontFamily: 'Uthmanic',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Chip(
                    backgroundColor: Colors.white.withAlpha(38),
                    side: BorderSide.none,
                    label: Text(
                      selectedAudioSurah.translation,
                      style: const TextStyle(
                        fontSize: AppSpacing.size12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Surah ${selectedAudioSurah.number} • ${selectedAudioSurah.totalAyahs} Verses',
                    style: const TextStyle(
                      fontSize: AppSpacing.size13,
                      color: AppColors.emerald100,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                StreamBuilder<Duration>(
                  stream: audioPlayer.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = audioPlayer.duration ?? Duration.zero;

                    double currentSeconds = position.inSeconds.toDouble();
                    double maxSeconds = duration.inSeconds.toDouble();

                    if (maxSeconds <= 0) {
                      maxSeconds = 1.0;
                    }

                    if (currentSeconds > maxSeconds) {
                      currentSeconds = maxSeconds;
                    }

                    return Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.emerald600,
                            inactiveTrackColor: isDark
                                ? AppTheme.darkBorder
                                : Colors.grey.shade300,
                            thumbColor: AppColors.emerald600,
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: currentSeconds,
                            max: maxSeconds,
                            onChanged: (value) {
                              audioPlayer.seek(
                                Duration(
                                  seconds: value.toInt(),
                                ),
                              );
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: TextStyle(
                                color: subtextColor,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: TextStyle(
                                color: subtextColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Repeat Mode Button
                    IconButton(
                      onPressed: () async {
                        final repeatNotifier =
                        ref.read(repeatModeProvider.notifier);
                        final audio = ref.read(audioServiceProvider);

                        final newMode = switch (repeatNotifier.state) {
                          RepeatStates.off => RepeatStates.repeatAll,
                          RepeatStates.repeatAll => RepeatStates.repeatOne,
                          RepeatStates.repeatOne => RepeatStates.off,
                        };

                        repeatNotifier.state = newMode;
                        await audio.updateRepeatMode(newMode);
                      },
                      icon: Icon(
                        switch (repeatMode) {
                          RepeatStates.off => LucideIcons.repeat,
                          RepeatStates.repeatAll => LucideIcons.repeat,
                          RepeatStates.repeatOne => LucideIcons.repeat1,
                        },
                        color: switch (repeatMode) {
                          RepeatStates.off => isDark
                              ? AppTheme.darkTextSecondary
                              : AppColors.gray600,
                          RepeatStates.repeatAll => AppColors.emerald600,
                          RepeatStates.repeatOne => AppColors.emerald600,
                        },
                      ),
                    ),

                    // Previous Track Button
                    IconButton(
                      onPressed: () async {
                        await ref.read(audioServiceProvider).skipToPrevious();
                      },
                      icon: Icon(
                        LucideIcons.skipBack,
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : AppColors.gray900,
                      ),
                    ),

                    // Play / Pause Button
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.emerald600,
                      ),
                      child: IconButton(
                        icon: Icon(
                          playerState?.playing == true
                              ? LucideIcons.pause
                              : LucideIcons.play,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          final audio = ref.read(audioServiceProvider);
                          final currentReciter =
                          ref.read(selectedReciterProvider);
                          final surah = ref.read(selectedAudioSurahProvider);
                          final surahs = ref.read(surahListProvider).value;

                          if (playerState?.playing == true) {
                            await audio.pause();
                            return;
                          }

                          if (!audio.hasLoadedSurah &&
                              currentReciter != null &&
                              surah != null &&
                              surahs != null) {
                            await audio.playSurah(
                              reciter: currentReciter,
                              surah: surah,
                              allSurahs: surahs,
                            );
                            return;
                          }

                          await audio.play();
                        },
                      ),
                    ),

                    // Next Track Button
                    IconButton(
                      onPressed: () async {
                        await ref.read(audioServiceProvider).skipToNext();
                      },
                      icon: Icon(
                        LucideIcons.skipForward,
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : AppColors.gray900,
                      ),
                    ),

                    // Volume Increment Button
                    IconButton(
                      onPressed: () {
                        final volumeNotifier =
                        ref.read(volumeProvider.notifier);
                        final audio = ref.read(audioServiceProvider);

                        final newVolume =
                        (volumeNotifier.state + 0.05).clamp(0.0, 1.0);

                        volumeNotifier.state = newVolume;
                        audio.setVolume(newVolume);
                      },
                      icon: Icon(
                        LucideIcons.volume2,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      volume == 0
                          ? LucideIcons.volumeX
                          : volume <= 0.5
                          ? LucideIcons.volume1
                          : LucideIcons.volume2,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppColors.gray400,
                      size: 22,
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.emerald600,
                          inactiveTrackColor: isDark
                              ? AppTheme.darkBorder
                              : Colors.grey.shade300,
                          thumbColor: AppColors.emerald600,
                          trackHeight: 3,
                        ),
                        child: Slider(
                          value: volume,
                          max: 1,
                          onChanged: (value) {
                            ref.read(volumeProvider.notifier).state = value;
                            ref.read(audioServiceProvider).setVolume(value);
                          },
                        ),
                      ),
                    ),
                    Text(
                      '${(volume * 100).toInt()}%',
                      style: TextStyle(
                        color:
                        isDark ? AppTheme.darkTextSecondary : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: PlayerCardButtons(
                        icon: LucideIcons.share,
                        text: 'Share',
                        onPressed: () async {
                          if (reciter != null) {
                            final surahNumStr = selectedAudioSurah.number
                                .toString()
                                .padLeft(3, '0');

                            final shareText =
                                'Listen to Surah ${selectedAudioSurah.nameEnglish} by ${reciter.name}:\n'
                                '${reciter.serverUrl}/$surahNumStr.mp3';

                            await SharePlus.instance.share(
                              ShareParams(
                                text: shareText,
                                subject:
                                'Surah ${selectedAudioSurah.nameEnglish}',
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PlayerCardButtons(
                        icon: LucideIcons.download,
                        text: 'Download',
                        onPressed: () async {
                          if (reciter != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Downloading Surah ${selectedAudioSurah.nameEnglish}...',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );

                            final manager = ref.read(
                              downloadManagerProvider.notifier,
                            );

                            await manager.downloadSurah(
                              reciter: reciter,
                              surah: selectedAudioSurah,
                              onCompleted: () {
                                ref
                                    .read(
                                  downloadRefreshTriggerProvider.notifier,
                                )
                                    .state++;

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Surah ${selectedAudioSurah.nameEnglish} downloaded!',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}