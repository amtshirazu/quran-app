import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/core/theme/app_theme.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_provider.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_states.dart';

import '../../../../core/constants/app_spacing.dart';

class BookmarkTabs extends ConsumerWidget {
  const BookmarkTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(bookmarkTabProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.black.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(bookmarkTabProvider.notifier).state = tab;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 20),
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.emerald600
                : (isDark ? AppTheme.darkScaffold : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.emerald600.withAlpha(51),
                      blurRadius: 4,
                    ),
                  ]
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
                  size: AppSpacing.size14,
                  color: isSelectedColor(isActive, isDark),
                ),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isSelectedColor(isActive, isDark),
                    fontSize: AppSpacing.size13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color isSelectedColor(bool isActive, bool isDark) {
    if (isActive) return Colors.white;
    return isDark ? AppTheme.darkTextSecondary : Colors.white;
  }
}
