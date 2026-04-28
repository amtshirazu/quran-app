import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_provider.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_states.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/state/reading_mode.dart';

class EmptyBookmarksState extends ConsumerWidget {
  const EmptyBookmarksState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(bookmarkTabProvider);

    // Define properties based on the active tab
    String title;
    String subtitle;
    IconData icon;
    Color themeColor;
    String buttonText;

    switch (activeTab) {
      case BookmarkTab.verses:
        title = "No Verse Bookmarks";
        subtitle =
            "Bookmark meaningful verses as you read to save them for later reflection and study.";
        icon = LucideIcons.bookmark;
        themeColor = const Color(0xFFD97706); // Orange
        buttonText = "Browse Surahs";
        ref.read(readingModeProvider.notifier).state = ReadingMode
            .translation; // Set reading mode to translation when exploring verses
        break;
      case BookmarkTab.pages:
        title = "No Page Bookmarks";
        subtitle =
            "Bookmark pages to mark where you stopped reading and continue your journey through the Quran.";
        icon = LucideIcons.bookOpen;
        themeColor = const Color(
          0xFFD97706,
        ); // Emerald/Green (as per your image)
        buttonText = "Start Reading";
        ref.read(readingModeProvider.notifier).state = ReadingMode
            .reading; // Set reading mode to translation when exploring pages
        break;
      default: // BookmarkTab.all
        title = "No Bookmarks Yet";
        subtitle =
            "Start bookmarking your favorite verses and pages to access them quickly. Your bookmarks will appear here.";
        icon = LucideIcons.bookmark;
        themeColor = const Color(0xFFD97706); // Orange
        buttonText = "Explore Quran";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular Icon Container
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: themeColor),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A), // Dark Blue/Gray
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Action Button
          SizedBox(
            width: 180,
            child: ElevatedButton(
              onPressed: () => context.go('/surahs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
