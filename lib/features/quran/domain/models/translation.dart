class Translation {
  final int surahNumber;
  final int ayahNumber;
  final String text;

  Translation({
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
  });

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      surahNumber: json['surah_number'],
      ayahNumber: json['ayah_number'],
      text: json['text'],
    );
  }
}
