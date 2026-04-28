import 'package:quran_app/features/quran/domain/models/surah.dart';

class ContinueReadingData {
  final Surah surah;
  final String displayText;
  final double progress;

  ContinueReadingData({
    required this.surah,
    required this.displayText,
    required this.progress,
  });
}
