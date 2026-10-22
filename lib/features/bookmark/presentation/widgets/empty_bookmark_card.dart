import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_provider.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_states.dart';

import '../../../../core/constants/app_spacing.dart';

class EmptyBookmarksCard extends ConsumerWidget {
  const EmptyBookmarksCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(bookmarkTabProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String title;
    String subtitle;
    IconData icon;
    String buttonText;

    switch (activeTab) {
      case BookmarkTab.verses:
        title = "No Verse Bookmarks";
        subtitle =
            "Bookmark meaningful verses as you read to save them for later reflection and study.";
        icon = LucideIcons.bookmark;
        buttonText = "Browse Surahs";
        break;
      case BookmarkTab.pages:
        title = "No Page Bookmarks";
        subtitle =
            "Bookmark pages to mark where you stopped reading and continue your journey through the Quran.";
        icon = LucideIcons.bookOpen;
        buttonText = "Start Reading";
        break;
      default:
        title = "No Bookmarks Yet";
        subtitle =
            "Start bookmarking your favorite verses and pages to access them quickly. Your bookmarks will appear here.";
        icon = LucideIcons.bookmark;
        buttonText = "Explore Quran";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.emerald600.withAlpha(38)
                  : AppColors.emerald100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 25, color: AppColors.emerald600),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: AppSpacing.size16,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppTheme.darkTextPrimary
                  : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSpacing.size12,
              color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 160,
            child: ElevatedButton(
              onPressed: () => context.go('/surahs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSpacing.size12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
