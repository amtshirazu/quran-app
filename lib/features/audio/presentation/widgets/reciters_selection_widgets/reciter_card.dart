import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../domain/models/Reciters.dart';

class ReciterCard extends StatelessWidget {
  const ReciterCard({super.key, required this.reciter, required this.onTap});

  final Reciter reciter;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: isDark ? 0 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isDark
              ? const BorderSide(color: AppTheme.darkBorder)
              : BorderSide.none,
        ),
        color: isDark ? AppTheme.darkSurface : Colors.white,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Top Image Section
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 125,
                  child: Image.asset(reciter.image, fit: BoxFit.cover),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(180),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(230),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      reciter.country,
                      style: const TextStyle(
                        fontSize: AppSpacing.size8,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  left: 8,
                  right: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        reciter.name,
                        style: const TextStyle(
                          fontSize: AppSpacing.size11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          reciter.arabicName,
                          style: const TextStyle(
                            fontSize: AppSpacing.size8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// Bottom Compact Details Section
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          reciter.riwayah,
                          style: TextStyle(
                            fontSize: AppSpacing.size10,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          reciter.style,
                          style: const TextStyle(
                            fontSize: AppSpacing.size8,
                            fontWeight: FontWeight.w600,
                            color: AppColors.emerald600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${reciter.totalSurahs} Surahs",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppTheme.darkTextPrimary
                                : Colors.black87,
                            fontSize: AppSpacing.size8,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: AppColors.emerald600,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.play,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
