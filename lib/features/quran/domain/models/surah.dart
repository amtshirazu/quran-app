class Surah {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final int totalAyahs;
  final String translation;
  final String revelationType;

  Surah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.totalAyahs,
    required this.translation,
    required this.revelationType,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      nameArabic: json['name_arabic'],
      nameEnglish: json['name_english'],
      totalAyahs: json['total_ayahs'],
      translation: json['translation'],
      revelationType: json['revelation_type'],
    );
  }
}
