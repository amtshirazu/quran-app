import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/audio/data/reciters_list.dart';
import 'package:quran_app/features/audio/domain/models/Reciters.dart';
import 'package:quran_app/features/audio/presentation/state/audio_providers.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';

import '../../../../core/constants/app_spacing.dart';

class ReciterSelectionScreen extends ConsumerStatefulWidget {
  const ReciterSelectionScreen({super.key});

  @override
  ConsumerState<ReciterSelectionScreen> createState() =>
      _ReciterSelectionScreenState();
}

class _ReciterSelectionScreenState
    extends ConsumerState<ReciterSelectionScreen> {
  String _searchQuery = '';
  String? _playingSampleId;

  Future<void> _toggleSamplePlay(Reciter reciter) async {
    final audio = ref.read(audioServiceProvider);
    final surahs = ref.read(surahListProvider).value;

    if (_playingSampleId == reciter.id && audio.player.playing) {
      await audio.pause();
      setState(() => _playingSampleId = null);
      return;
    }

    if (surahs != null && surahs.isNotEmpty) {
      setState(() => _playingSampleId = reciter.id);
      await audio.playSurah(
        reciter: reciter,
        surah: surahs.first,
        allSurahs: surahs,
      );
    }
  }

  void _stopAudioAndPop() {
    final audio = ref.read(audioServiceProvider);
    if (audio.player.playing) {
      audio.pause();
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedReciter = ref.watch(defaultReciterProvider);
    final playerState = ref.watch(audioStreamProvider).value;
    final isAudioPlaying = playerState?.playing == true;

    final filteredReciters = reciters.where((r) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return r.name.toLowerCase().contains(q) ||
          r.country.toLowerCase().contains(q) ||
          r.style.toLowerCase().contains(q);
    }).toList();

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        final audio = ref.read(audioServiceProvider);
        if (audio.player.playing) {
          audio.pause();
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppTheme.darkScaffold
            : AppTheme.lightScaffold,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkScaffold : null,
              gradient: isDark
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.deepGreen, AppColors.emerald600],
                    ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 10, 16, 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                LucideIcons.arrowLeft,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _stopAudioAndPop,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Choose a reciter',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppSpacing.size16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _stopAudioAndPop,
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppSpacing.size12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    /// Search Bar
                    Container(
                      margin: const EdgeInsets.only(left: 24, right: 16),
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: isDark
                            ? Border.all(color: AppTheme.darkBorder)
                            : null,
                      ),
                      child: TextField(
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (val) {
                          setState(() => _searchQuery = val);
                        },
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.gray900,
                          fontSize: AppSpacing.size12,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'Search reciters',
                          hintStyle: TextStyle(
                            color: AppColors.gray400,
                            fontSize: AppSpacing.size11,
                          ),
                          prefixIcon: Icon(
                            LucideIcons.search,
                            color: AppColors.gray400,
                            size: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 1. SELECTED SECTION
              Text(
                'SELECTED',
                style: TextStyle(
                  fontSize: AppSpacing.size13,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppTheme.darkCategoryTitle
                      : AppColors.emerald600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),

              /// Highlighted Selected Reciter Card
              if (selectedReciter != null) ...[
                Builder(
                  builder: (context) {
                    final isPlayingSelected =
                        isAudioPlaying &&
                        (_playingSampleId == selectedReciter.id);

                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkSurface
                            : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.emerald600,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              selectedReciter.image,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedReciter.name,
                                  style: TextStyle(
                                    fontSize: AppSpacing.size13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppTheme.darkTextPrimary
                                        : AppColors.gray900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${selectedReciter.style} • Default',
                                  style: const TextStyle(
                                    fontSize: AppSpacing.size10,
                                    color: AppColors.emerald600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isPlayingSelected
                                  ? LucideIcons.pauseCircle
                                  : LucideIcons.playCircle,
                              color: AppColors.emerald600,
                              size: 26,
                            ),
                            onPressed: () => _toggleSamplePlay(selectedReciter),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 24),

              /// 2. ALL RECITERS SECTION
              Text(
                'ALL RECITERS',
                style: TextStyle(
                  fontSize: AppSpacing.size13,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppTheme.darkCategoryTitle
                      : AppColors.gray700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),

              /// Reciters List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredReciters.length,
                separatorBuilder: (_, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final reciter = filteredReciters[index];
                  final isSelected = selectedReciter?.id == reciter.id;
                  final isPlayingThisCard =
                      isAudioPlaying && (_playingSampleId == reciter.id);

                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.emerald600
                            : (isDark
                                  ? AppTheme.darkBorder
                                  : AppColors.gray200),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          ref
                              .read(defaultReciterProvider.notifier)
                              .setReciter(reciter);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  reciter.image,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reciter.name,
                                      style: TextStyle(
                                        fontSize: AppSpacing.size13,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppTheme.darkTextPrimary
                                            : AppColors.gray900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${reciter.style} • ${reciter.country}',
                                      style: TextStyle(
                                        fontSize: AppSpacing.size10,
                                        color: isDark
                                            ? AppTheme.darkTextSecondary
                                            : AppColors.gray600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isPlayingThisCard
                                      ? LucideIcons.pauseCircle
                                      : LucideIcons.playCircle,
                                  color: AppColors.emerald600,
                                  size: 24,
                                ),
                                onPressed: () => _toggleSamplePlay(reciter),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: isSelected
                                    ? AppColors.emerald600
                                    : AppColors.gray400,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
