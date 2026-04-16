



class ContinueReadingData {
  final int surahId;
  final String surahName;
  final int? ayah;
  final int? page;
  final String mode;
  final double progress;

  ContinueReadingData({
    required this.surahId,
    required this.surahName,
    required this.mode,
    required this.progress,
    this.ayah,
    this.page,
  });
}