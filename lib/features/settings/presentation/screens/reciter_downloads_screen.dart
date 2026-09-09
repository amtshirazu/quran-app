import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/audio/domain/models/Reciters.dart';
import 'package:quran_app/features/quran/domain/models/surah.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/settings/presentation/state/download_provider.dart';

class ReciterDownloadsScreen extends ConsumerWidget {
  final Reciter reciter;

  const ReciterDownloadsScreen({
    super.key,
    required this.reciter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surahsAsync = ref.watch(surahListProvider);
    final fileDetailsAsync = ref.watch(reciterFileDetailsProvider(reciter));

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkScaffold : null,
            gradient: isDark
                ? null
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.deepGreen,
                      AppColors.emerald600,
                    ],
                  ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
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
                          size: 22,
                        ),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/downloads');
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        reciter.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () async {
                      final manager = ref.read(downloadManagerProvider.notifier);
                      await manager.deleteAllReciterSurahs(
                        reciter: reciter,
                        onCompleted: () {
                          ref.read(downloadRefreshTriggerProvider.notifier).state++;
                        },
                      );
                    },
                    child: const Text(
                      'Delete All',
                      style: TextStyle(
                        color: Color(0xFFFF8A80),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: surahsAsync.when(
        data: (surahList) {
          final fileDetails = fileDetailsAsync.asData?.value;
          final downloadedMap = fileDetails?.downloadedSurahSizeMap ?? {};
          final totalDownloadedCount = fileDetails?.downloadedCount ?? 0;
          final totalMb = fileDetails?.formattedTotalSize ?? '0.0 MB';

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Subtitle Summary
                Text(
                  '$totalDownloadedCount of 114 surahs downloaded • $totalMb',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppColors.gray600,
                  ),
                ),
                const SizedBox(height: 16),

                /// Surahs List Container
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppTheme.darkBorder : AppColors.gray200,
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: surahList.length,
                    separatorBuilder: (_, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark ? AppTheme.darkBorder : const Color(0xFFF3F4F6),
                    ),
                    itemBuilder: (context, index) {
                      final surah = surahList[index];
                      final sizeBytes = downloadedMap[surah.number];
                      final isDownloaded = sizeBytes != null;

                      return _SurahDownloadItemTile(
                        surah: surah,
                        reciter: reciter,
                        isDownloaded: isDownloaded,
                        sizeBytes: sizeBytes ?? 0.0,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.emerald600),
        ),
        error: (err, _) => Center(child: Text('Error loading surahs: $err')),
      ),
    );
  }
}

class _SurahDownloadItemTile extends ConsumerWidget {
  final Surah surah;
  final Reciter reciter;
  final bool isDownloaded;
  final double sizeBytes;

  const _SurahDownloadItemTile({
    required this.surah,
    required this.reciter,
    required this.isDownloaded,
    required this.sizeBytes,
  });

  String get formattedSize {
    if (sizeBytes <= 0) return '0 MB';
    final mb = sizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = ref.watch(
      downloadManagerProvider,
    )['${reciter.id}_${surah.number}'];
    final isDownloading = progress != null;

    return InkWell(
      onTap: () async {
        if (!isDownloaded && !isDownloading) {
          final manager = ref.read(downloadManagerProvider.notifier);
          await manager.downloadSurah(
            reciter: reciter,
            surah: surah,
            onCompleted: () {
              ref.read(downloadRefreshTriggerProvider.notifier).state++;
            },
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                /// Left Icon
                if (isDownloading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.emerald600,
                    ),
                  )
                else if (isDownloaded)
                  Text(
                    '${surah.number}.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppColors.gray900,
                    ),
                  )
                else
                  const Icon(
                    LucideIcons.download,
                    size: 18,
                    color: AppColors.gray400,
                  ),
                const SizedBox(width: 12),

                /// Surah Name
                Expanded(
                  child: Text(
                    isDownloaded
                        ? surah.nameEnglish
                        : '${surah.number}. ${surah.nameEnglish}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppColors.gray900,
                    ),
                  ),
                ),

                /// Right Trailing State
                if (isDownloading)
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.emerald600,
                    ),
                  )
                else if (isDownloaded)
                  Row(
                    children: [
                      Text(
                        formattedSize,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppColors.gray500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          LucideIcons.trash2,
                          size: 18,
                          color: Color(0xFFE53935),
                        ),
                        onPressed: () async {
                          final manager = ref.read(
                            downloadManagerProvider.notifier,
                          );
                          await manager.deleteSurah(
                            reciter: reciter,
                            surahNum: surah.number,
                            onCompleted: () {
                              ref
                                  .read(
                                    downloadRefreshTriggerProvider
                                        .notifier,
                                  )
                                  .state++;
                            },
                          );
                        },
                      ),
                    ],
                  )
                else
                  const Text(
                    'Not downloaded',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.gray400,
                    ),
                  ),
              ],
            ),

            /// Active Download Linear Progress Bar
            if (isDownloading) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark
                    ? AppTheme.darkBorder
                    : AppColors.gray200,
                valueColor: const AlwaysStoppedAnimation(
                  AppColors.emerald600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
