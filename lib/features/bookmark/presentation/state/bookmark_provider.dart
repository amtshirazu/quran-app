import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/bookmark/domain/model/bookmark.dart';
import 'package:quran_app/features/bookmark/domain/model/page_model.dart';
import 'package:quran_app/features/bookmark/domain/model/verse_model.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_service.dart';
import 'package:quran_app/features/bookmark/presentation/state/bookmark_states.dart';
import 'package:quran_app/features/quran/presentation/state/quran_providers.dart';

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
  final service = ref.watch(bookmarkServiceProvider);
  final bookmarks = await service.getVerseBookmarks();

  final surahList = await ref.watch(surahListProvider.future);

  List<VerseBookmarkUI> result = [];

  for (final b in bookmarks) {
    final surah = surahList.firstWhere((s) => s.number == b.surahId);

    final ayahs = await ref.read(
      ayahListProvider({"surahNumber": b.surahId, "script": "uthmani"}).future,
    );

    final translations = await ref.read(
      translationListProvider({
        "surahNumber": b.surahId,
        "translationFile": "saheeh",
      }).future,
    );

    final ayah = ayahs.firstWhere(
      (a) => a.ayahNumber == b.ayahNumber,
      orElse: () => ayahs.first,
    );

    final translation = translations.firstWhere(
      (t) => t.ayahNumber == b.ayahNumber,
      orElse: () => translations.first,
    );

    result.add(
      VerseBookmarkUI(
        bookmark: b,
        surah: surah,
        arabic: ayah.text,
        translation: translation.text,
      ),
    );
  }

  return result;
});

final pageBookmarkUIProvider = FutureProvider<List<PageBookmarkUI>>((
  ref,
) async {
  final service = ref.watch(bookmarkServiceProvider);
  final bookmarks = await service.getPageBookmarks();

  final surahList = await ref.watch(surahListProvider.future);

  List<PageBookmarkUI> result = [];

  for (final b in bookmarks) {
    final page = b.page!;

    /// 1. Get ALL ayahs on this page (structure only)
    final pageAyahs = await ref.read(pageAyahsProvider(page).future);

    if (pageAyahs.isEmpty) continue;

    /// 2. Pick first ayah on page (preview anchor)
    final firstPageAyah = pageAyahs.first;

    final surahId = firstPageAyah.surah;
    final ayahNumber = firstPageAyah.ayah;
    final juzNumber = firstPageAyah.juz;

    /// 3. Get Arabic text for that surah (UTHMANI)
    final arabicAyahs = await ref.read(
      ayahListProvider({"surahNumber": surahId, "script": "uthmani"}).future,
    );

    final arabic = arabicAyahs.firstWhere(
      (a) => a.ayahNumber == ayahNumber,
      orElse: () => arabicAyahs.first,
    );

    /// 4. Surah metadata
    final surah = surahList.firstWhere(
      (s) => s.number == surahId,
      orElse: () => surahList.first,
    );

    result.add(
      PageBookmarkUI(
        bookmark: b,
        surahName: surah.nameEnglish,
        juz: juzNumber,
        arabicPreview: arabic.text,
      ),
    );
  }

  return result;
});
