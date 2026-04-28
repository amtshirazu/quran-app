class PagedAyah {
  final int surah;
  final int ayah;
  final int page;
  final int juz;
  final String polygon;

  PagedAyah({
    required this.surah,
    required this.ayah,
    required this.page,
    required this.juz,
    required this.polygon,
  });

  factory PagedAyah.fromJson(Map<String, dynamic> json) {
    return PagedAyah(
      surah: (json['surahNumber'] as num).toInt(),
      ayah: (json['ayahNumber'] as num).toInt(),
      page: (json['page_number'] as num).toInt(),
      juz: (json['juz'] as num).toInt(),
      polygon: json['polygon'] as String,
    );
  }
}
