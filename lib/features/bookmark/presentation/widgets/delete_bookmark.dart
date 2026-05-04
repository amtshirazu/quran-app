import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_provider.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_states.dart';

Future<void> handleDeleteAction(BuildContext context, WidgetRef ref) async {
  final activeTab = ref.read(bookmarkTabProvider);
  final service = ref.read(bookmarkServiceProvider);

  String title = "Clear ";
  String content = "Are you sure you want to remove ";

  if (activeTab == BookmarkTab.all) {
    title += "All Bookmarks";
    content += "all your saved items?";
  } else if (activeTab == BookmarkTab.verses) {
    title += "Verse Bookmarks";
    content += "all bookmarked verses?";
  } else {
    title += "Page Bookmarks";
    content += "all bookmarked pages?";
  }

  bool confirm =
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          surfaceTintColor: Colors.white,
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111827), // Deep Gray
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            content,
            style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 15),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(0, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Color(0xFF71717A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEF2F2), // Very light red
                foregroundColor: const Color(0xFFDC2626), // Sharp red
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Delete All",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ) ??
      false;

  if (!confirm) return;

  if (activeTab == BookmarkTab.all) {
    await service.deleteAllBookmarks();
  } else if (activeTab == BookmarkTab.verses) {
    await service.deleteAllVerseBookmarks();
  } else {
    await service.deleteAllPageBookmarks();
  }

  ref.invalidate(bookmarksProvider);
  ref.invalidate(verseBookmarkUIProvider);
  ref.invalidate(pageBookmarkUIProvider);
}
