import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/bookmark/domain/model/bookmark.dart';
import 'package:quran_app/features/bookmark/domain/model/page_model.dart';
import 'package:quran_app/features/bookmark/domain/model/verse_model.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_service.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_states.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';
import 'package:quran_app/features/quran/presentation/state/translation_provider.dart';
import 'package:quran/quran.dart' as quran;

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

final isBookmarksEmptyProvider = Provider<bool>((ref) {
  final list = ref.watch(filteredBookmarksProvider);
  return list.isEmpty;
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

final verseBookmarkUIProvider = FutureProvider<List<VerseBookmarkUI>>((
  ref,
) async {
  final allBookmarks = await ref.watch(bookmarksProvider.future);
  final verseData = allBookmarks
      .where((b) => b.type == BookmarkType.verse)
      .toList();
  final surahList = await ref.watch(surahListProvider.future);

  // Access our new SQLite service
  final translationService = ref.read(translationServiceProvider);

  List<VerseBookmarkUI> result = [];

  for (final b in verseData) {
    try {
      final surah = surahList.firstWhere((s) => s.number == b.surahId);

      final arabicText = quran.getVerse(b.surahId!, b.ayahNumber!);

      final translationText = await translationService.getTranslation(
        b.surahId!,
        b.ayahNumber!,
      );

      result.add(
        VerseBookmarkUI(
          bookmark: b,
          surah: surah,
          arabic: arabicText,
          translation: translationText,
        ),
      );
    } catch (e) {
      debugPrint("Error loading bookmark UI for Surah ${b.surahId}: $e");
    }
  }
  return result;
});

final pageBookmarkUIProvider = FutureProvider<List<PageBookmarkUI>>((
  ref,
) async {
  final allBookmarks = await ref.watch(bookmarksProvider.future);
  final pageData = allBookmarks
      .where((b) => b.type == BookmarkType.page)
      .toList();
  final surahList = await ref.watch(surahListProvider.future);

  List<PageBookmarkUI> result = [];

  for (final b in pageData) {
    final page = b.page!;

    final List<Map<String, dynamic>> pageVerses = quran
        .getPageData(page)
        .cast<Map<String, dynamic>>();

    if (pageVerses.isEmpty) continue;

    final firstVerse = pageVerses.first;
    final surahId = firstVerse['surah'];
    final ayahId = firstVerse['ayah'];

    final arabicPreview = quran.getVerse(surahId!, ayahId!);

    final surah = surahList.firstWhere(
      (s) => s.number == surahId,
      orElse: () => surahList.first,
    );

    final juz = quran.getJuzNumber(surahId!, ayahId!);

    result.add(
      PageBookmarkUI(
        bookmark: b,
        surahName: surah.nameEnglish,
        juz: juz,
        arabicPreview: arabicPreview,
      ),
    );
  }
  return result;
});
