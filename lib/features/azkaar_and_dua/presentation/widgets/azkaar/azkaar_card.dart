import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/settings/presentation/state/display_settings_provider.dart';

class AzkarItemCard extends ConsumerWidget {
  final AzkarItem item;
  const AzkarItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final quranScript = ref.watch(quranScriptProvider);
    final ayahTextSize = ref.watch(ayahTextSizeProvider);
    final translationTextSize = ref.watch(translationTextSizeProvider);
    final referenceTextSize = ref.watch(referenceTextSizeProvider);

    final fontName = quranScript == 'IndoPak' ? "Indo Park" : "Uthmanic";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item.item,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: ayahTextSize,
                fontWeight: FontWeight.bold,
                height: 1.8,
                color: isDark
                    ? AppTheme.darkTextPrimary
                    : const Color(0xFF2D3436),
                fontFamily: fontName,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Divider(
                color: isDark ? AppTheme.darkBorder : const Color(0xFFE0F2F1),
                thickness: 1,
              ),
            ),
            Text(
              item.translation,
              style: TextStyle(
                fontSize: translationTextSize,
                height: 1.5,
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : const Color(0xFF636E72),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.darkScaffold
                      : const Color(0xFFF1F8F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.reference,
                  style: TextStyle(
                    fontSize: referenceTextSize,
                    color: AppColors.emerald600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
