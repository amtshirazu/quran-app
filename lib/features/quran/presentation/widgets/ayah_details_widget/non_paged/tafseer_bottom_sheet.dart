import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/quran/presentation/state/tafseer_provider.dart';

Future<void> showTafseerBottomSheet(
  BuildContext context, {
  required String surahName,
  required int surahNumber,
  required int ayahNumber,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _TafseerBottomSheetContent(
        surahName: surahName,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
      );
    },
  );
}

class _TafseerBottomSheetContent extends ConsumerWidget {
  final String surahName;
  final int surahNumber;
  final int ayahNumber;

  const _TafseerBottomSheetContent({
    required this.surahName,
    required this.surahNumber,
    required this.ayahNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tafseerAsync = ref.watch(
      verseTafseerProvider((surah: surahNumber, verse: ayahNumber)),
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          /// Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkBorder : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          /// Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.emerald600.withAlpha(38)
                        : AppColors.emerald100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.bookOpen,
                    color: AppColors.emerald600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Surah $surahName, Ayah $ayahNumber',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      tafseerAsync.when(
                        data: (data) => Text(
                          data.model.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.emerald600,
                          ),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppColors.gray600,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? AppTheme.darkBorder : const Color(0xFFF3F4F6),
          ),

          /// Tafseer Content
          Expanded(
            child: tafseerAsync.when(
              data: (data) {
                final isArabic = data.model.languageCode == 'ar';

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: SelectableText(
                    data.content,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    style: TextStyle(
                      fontSize: isArabic ? 18 : 15,
                      height: 1.7,
                      fontFamily: isArabic ? 'Uthmanic' : null,
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppColors.gray900,
                    ),
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.emerald600),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Error loading Tafseer: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
