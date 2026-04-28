import 'package:quran_app/features/bookmark/domain/model/bookmark.dart';
import 'package:quran_app/features/quran/domain/models/surah.dart';

class VerseBookmarkUI {
  final Bookmark bookmark;
  final Surah surah;
  final String arabic;
  final String translation;

  VerseBookmarkUI({
    required this.bookmark,
    required this.surah,
    required this.arabic,
    required this.translation,
  });
}
