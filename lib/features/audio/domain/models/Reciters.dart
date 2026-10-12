class Reciter {
  final String id;
  final String name;
  final String arabicName;
  final String image;
  final String country;
  final String riwayah;
  final String style;
  final int totalSurahs;

  /// Full Surah local folder and CDN server URL (e.g. mp3quran)
  final String audioFolder;
  final String serverUrl;

  /// Dedicated Ayah CDN and local folder (e.g. EveryAyah)
  final String? ayahServerUrl;
  final String? ayahAudioFolder;

  const Reciter({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.image,
    required this.country,
    required this.riwayah,
    required this.style,
    required this.totalSurahs,
    required this.audioFolder,
    required this.serverUrl,
    this.ayahServerUrl,
    this.ayahAudioFolder,
  });
}