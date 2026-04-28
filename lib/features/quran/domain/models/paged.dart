class PagedAyah {
  final int surah;
  final int ayah;
  final int page;
  final String juz;
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
      surah: json['surahNumber'],
      ayah: json['ayahNumber'],
      page: json['page_number'],
      juz: json['juz'],
      polygon: json['polygon'],
    );
  }
}
