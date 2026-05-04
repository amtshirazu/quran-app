import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/core/constants/app_colors.dart';
import 'package:quran_app/features/bookmark/domain/model/page_model.dart';
import 'package:quran_app/features/bookmark/domain/model/verse_model.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_provider.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_states.dart';
import 'package:quran_app/features/bookmark/presentation/widgets/ayah_bookmark_card.dart';
import 'package:quran_app/features/bookmark/presentation/widgets/empty_bookmark_card.dart';
import 'package:quran_app/features/bookmark/presentation/widgets/page_bookmark_card.dart';

// ... imports

class BookmarkBody extends ConsumerWidget {
  const BookmarkBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(bookmarkTabProvider);
    final isEmpty = ref.watch(isBookmarksEmptyProvider);

    final verseAsync = ref.watch(verseBookmarkUIProvider);
    final pageAsync = ref.watch(pageBookmarkUIProvider);

    if (isEmpty) {
      return Center(child: EmptyBookmarksCard());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: _buildContent(tab, verseAsync, pageAsync),
    );
  }

  Widget _buildContent(
    BookmarkTab tab,
    AsyncValue<List<VerseBookmarkUI>> verseAsync,
    AsyncValue<List<PageBookmarkUI>> pageAsync,
  ) {
    switch (tab) {
      case BookmarkTab.verses:
        return verseAsync.when(
          data: (bookmarks) => ListView.separated(
            itemCount: bookmarks.length,

            separatorBuilder: (_, __) => const SizedBox(height: 24),
            itemBuilder: (context, i) => VerseBookmarkCard(bookmarks[i]),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text("Error loading verses"),
        );

      case BookmarkTab.pages:
        return pageAsync.when(
          data: (pages) => ListView.separated(
            itemCount: pages.length,

            separatorBuilder: (_, __) => const SizedBox(height: 24),
            itemBuilder: (context, i) => PageBookmarkCard(pages[i]),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text("Error loading pages"),
        );

      case BookmarkTab.all:
        return _buildAll(verseAsync, pageAsync);
    }
  }

  Widget _buildAll(
    AsyncValue<List<VerseBookmarkUI>> verseAsync,
    AsyncValue<List<PageBookmarkUI>> pageAsync,
  ) {
    return ListView(
      children: [
        verseAsync.when(
          data: (list) => list.isEmpty
              ? const SizedBox()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader("Verse Bookmarks"),

                    ...list.map(
                      (b) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: VerseBookmarkCard(b),
                      ),
                    ),
                  ],
                ),
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Text("Error"),
        ),

        const SizedBox(height: 30),

        pageAsync.when(
          data: (list) => list.isEmpty
              ? const SizedBox()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader("Page Bookmarks"),

                    ...list.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: PageBookmarkCard(p),
                      ),
                    ),
                  ],
                ),
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Text("Error"),
        ),
      ],
    );
  }

  // Helper to keep code clean
  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(LucideIcons.bookmark, size: 20, color: AppColors.gray500),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
