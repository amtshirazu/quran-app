import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_provider.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_states.dart';

class BookmarkTabs extends ConsumerWidget {
  const BookmarkTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current active tab to trigger rebuilds when it changes
    final activeTab = ref.watch(bookmarkTabProvider);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _TabButton(text: "All", tab: BookmarkTab.all, activeTab: activeTab),
          _TabButton(
            text: "Verses",
            tab: BookmarkTab.verses,
            activeTab: activeTab,
          ),
          _TabButton(
            text: "Pages",
            tab: BookmarkTab.pages,
            activeTab: activeTab,
          ),
        ],
      ),
    );
  }
}

class _TabButton extends ConsumerWidget {
  final String text;
  final BookmarkTab tab;
  final BookmarkTab activeTab;

  const _TabButton({
    required this.text,
    required this.tab,
    required this.activeTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = activeTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(bookmarkTabProvider.notifier).state = tab;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.black12, blurRadius: 4)]
                : [],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  tab == BookmarkTab.verses
                      ? LucideIcons.bookmark
                      : tab == BookmarkTab.pages
                      ? LucideIcons.bookOpen
                      : LucideIcons.layoutGrid,
                  size: 16,
                  color: isActive ? const Color(0xFFD97706) : Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? const Color(0xFFD97706) : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
