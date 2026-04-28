import 'package:quran_app/features/bookmark/domain/model/bookmark.dart';

class PageBookmarkUI {
  final Bookmark bookmark;
  final String surahName;
  final String juz;
  final String arabicPreview;

  PageBookmarkUI({
    required this.bookmark,
    required this.surahName,
    required this.juz,
    required this.arabicPreview,
  });
}
