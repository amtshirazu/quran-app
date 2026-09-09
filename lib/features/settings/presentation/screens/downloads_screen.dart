import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/settings/presentation/state/download_provider.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final downloadedRecitersAsync = ref.watch(downloadedRecitersProvider);
    final storageSummaryAsync = ref.watch(storageSummaryProvider);

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
                    colors: [AppColors.deepGreen, AppColors.emerald600],
                  ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Row(
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
                        context.go('/');
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Downloads',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
            /// 1. Storage Usage Card
            storageSummaryAsync.when(
              data: (summary) {
                final quranFlex =
                    (summary.quranTextBytes / summary.totalUsedBytes * 100)
                        .round()
                        .clamp(1, 100);
                final audioFlex =
                    (summary.audioBytes / summary.totalUsedBytes * 100)
                        .round()
                        .clamp(0, 100);
                final translationsFlex =
                    (summary.translationsBytes / summary.totalUsedBytes * 100)
                        .round()
                        .clamp(1, 100);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppTheme.darkBorder : AppColors.gray200,
                    ),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withAlpha(5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${summary.formattedTotalUsed} used',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppTheme.darkTextPrimary
                                  : AppColors.gray900,
                            ),
                          ),
                          Text(
                            '${summary.formattedFreeSpace} free storage',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      /// Multi-segment Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 8,
                          child: Row(
                            children: [
                              if (audioFlex > 0)
                                Expanded(
                                  flex: audioFlex,
                                  child: Container(color: AppColors.deepGreen),
                                ),
                              Expanded(
                                flex: translationsFlex,
                                child: Container(color: AppColors.emerald600),
                              ),
                              Expanded(
                                flex: quranFlex,
                                child: Container(color: AppColors.emerald300),
                              ),
                              Expanded(
                                flex: 20,
                                child: Container(
                                  color: isDark
                                      ? AppTheme.darkBorder
                                      : AppColors.gray200,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      /// Legend Row
                      Row(
                        children: [
                          _buildLegendItem(
                            'Audio',
                            AppColors.deepGreen,
                            isDark,
                          ),
                          const SizedBox(width: 12),
                          _buildLegendItem(
                            'Translations',
                            AppColors.emerald600,
                            isDark,
                          ),
                          const SizedBox(width: 12),
                          _buildLegendItem(
                            'Quran text',
                            AppColors.emerald300,
                            isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),

            /// 2. Section Title
            Text(
              'DOWNLOAD RECITATIONS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppTheme.darkCategoryTitle
                    : AppColors.emerald600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),

            /// 3. Downloaded Reciters List
            downloadedRecitersAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppColors.gray200,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.downloadCloud,
                          size: 40,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppColors.gray400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No downloaded recitations yet',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppTheme.darkTextPrimary
                                : AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Downloaded audio files will appear here for offline listening.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _ReciterDownloadTile(item: item);
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.emerald600),
                ),
              ),
              error: (err, _) =>
                  Center(child: Text('Error loading downloads: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppTheme.darkTextSecondary : AppColors.gray600,
          ),
        ),
      ],
    );
  }
}

class _ReciterDownloadTile extends ConsumerWidget {
  final ReciterDownloadInfo item;

  const _ReciterDownloadTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeMap = ref.watch(downloadManagerProvider);

    bool isDownloading = false;
    double currentProgress = 0.0;
    int? downloadingSurahNum;

    for (final key in activeMap.keys) {
      if (key.startsWith('${item.reciter.id}_')) {
        isDownloading = true;
        currentProgress = activeMap[key] ?? 0.0;
        final parts = key.split('_');
        if (parts.length > 1) {
          downloadingSurahNum = int.tryParse(parts.last);
        }
        break;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppColors.gray200,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push('/reciterDownloads', extra: item.reciter);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.emerald600.withAlpha(38)
                            : AppColors.emerald100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.headphones,
                        color: AppColors.emerald600,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.reciter.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppTheme.darkTextPrimary
                                  : AppColors.gray900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isDownloading
                                ? 'Downloading Surah ${downloadingSurahNum ?? ''} of 114...'
                                : '${item.downloadedCount} of ${item.totalSurahs} surahs • ${item.formattedSize}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDownloading
                                  ? AppColors.emerald600
                                  : (isDark
                                        ? AppTheme.darkTextSecondary
                                        : AppColors.gray500),
                              fontWeight: isDownloading
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.gray400,
                      size: 20,
                    ),
                  ],
                ),
                if (isDownloading) ...[
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: currentProgress,
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
        ),
      ),
    );
  }
}
