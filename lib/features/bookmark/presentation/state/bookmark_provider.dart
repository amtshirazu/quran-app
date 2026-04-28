import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/bookmark/domain/model/bookmark.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_service.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_states.dart';

final bookmarkServiceProvider = Provider<BookmarkService>((ref) {
  return BookmarkService();
});

final bookmarkTabProvider = StateProvider<BookmarkTab>(
  (ref) => BookmarkTab.all,
);

final bookmarksProvider = FutureProvider<List<Bookmark>>((ref) async {
  final service = ref.watch(bookmarkServiceProvider);
  return await service.getAllBookmarks();
});

final verseBookmarksProvider = Provider<AsyncValue<List<Bookmark>>>((ref) {
  final bookmarksAsync = ref.watch(bookmarksProvider);

  return bookmarksAsync.whenData(
    (bookmarks) =>
        bookmarks.where((b) => b.type == BookmarkType.verse).toList(),
  );
});

final pageBookmarksProvider = Provider<AsyncValue<List<Bookmark>>>((ref) {
  final bookmarksAsync = ref.watch(bookmarksProvider);

  return bookmarksAsync.whenData(
    (bookmarks) => bookmarks.where((b) => b.type == BookmarkType.page).toList(),
  );
});

final filteredBookmarksProvider = Provider<List<Bookmark>>((ref) {
  final tab = ref.watch(bookmarkTabProvider);
  final bookmarksAsync = ref.watch(bookmarksProvider);

  return bookmarksAsync.when(
    data: (data) {
      switch (tab) {
        case BookmarkTab.verses:
          return data.where((b) => b.type == BookmarkType.verse).toList();
        case BookmarkTab.pages:
          return data.where((b) => b.type == BookmarkType.page).toList();
        default:
          return data;
      }
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final totalCountProvider = Provider<int>((ref) {
  return ref.watch(filteredBookmarksProvider).length;
});

final isAyahBookmarkedProvider =
    Provider.family<bool, ({int surahId, int ayahNumber})>((ref, key) {
      final bookmarks = ref
          .watch(bookmarksProvider)
          .maybeWhen(data: (data) => data, orElse: () => const []);

      return bookmarks.any(
        (b) =>
            b.type == BookmarkType.verse &&
            b.surahId == key.surahId &&
            b.ayahNumber == key.ayahNumber,
      );
    });

final verseBookmarkActionProvider = Provider((ref) {
  final service = ref.watch(bookmarkServiceProvider);

  return ({required int surahId, required int ayahNumber}) async {
    await service.toggleVerseBookmark(surahId: surahId, ayahNumber: ayahNumber);

    ref.invalidate(bookmarksProvider); // refresh UI
  };
});

final isPageBookmarkedProvider = Provider.family<bool, ({int page})>((
  ref,
  key,
) {
  final bookmarks = ref
      .watch(bookmarksProvider)
      .maybeWhen(data: (data) => data, orElse: () => const []);

  return bookmarks.any(
    (b) => b.type == BookmarkType.page && b.page == key.page,
  );
});

final pageBookmarkActionProvider = Provider((ref) {
  final service = ref.watch(bookmarkServiceProvider);

  return ({required int page}) async {
    await service.togglePageBookmark(page: page);

    ref.invalidate(bookmarksProvider); // refresh UI
  };
});
