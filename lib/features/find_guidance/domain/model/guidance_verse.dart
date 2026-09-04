class GuidanceVerse {
  final int id;
  final int surahNum;
  final int ayahNum;
  final String emotion;
  final String whyThisVerse;
  final String? arabicText;
  final String? translation;
  final String? surahName;

  const GuidanceVerse({
    required this.id,
    required this.surahNum,
    required this.ayahNum,
    required this.emotion,
    required this.whyThisVerse,
    this.arabicText,
    this.translation,
    this.surahName,
  });

  factory GuidanceVerse.fromMap(Map<String, dynamic> map) {
    return GuidanceVerse(
      id: map['id'] as int,
      surahNum: map['surah_num'] as int,
      ayahNum: map['ayah_num'] as int,
      emotion: map['emotion'] as String,
      whyThisVerse: map['why_this_verse'] as String,
      arabicText: map['arabic_text'] as String?,
      translation: map['translation'] as String?,
      surahName: map['surah_name'] as String?,
    );
  }

  GuidanceVerse copyWith({
    int? id,
    int? surahNum,
    int? ayahNum,
    String? emotion,
    String? whyThisVerse,
    String? arabicText,
    String? translation,
    String? surahName,
  }) {
    return GuidanceVerse(
      id: id ?? this.id,
      surahNum: surahNum ?? this.surahNum,
      ayahNum: ayahNum ?? this.ayahNum,
      emotion: emotion ?? this.emotion,
      whyThisVerse: whyThisVerse ?? this.whyThisVerse,
      arabicText: arabicText ?? this.arabicText,
      translation: translation ?? this.translation,
      surahName: surahName ?? this.surahName,
    );
  }
}
