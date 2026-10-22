class Ayah {
  final int surahNumber;
  final int ayahNumber;
  final String text;

  Ayah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      surahNumber: json['surah_number'],
      ayahNumber: json['ayah_number'],
      text: json['text'],
    );
  }
}
