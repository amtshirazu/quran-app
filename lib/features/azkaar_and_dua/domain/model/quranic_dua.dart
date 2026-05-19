class QuranicDua {
  final int id;
  final int surahNum;
  final String ayahNum;
  final String arabic;
  final String? transliteration;
  final String translation;
  final String subject;

  QuranicDua({
    required this.id,
    required this.surahNum,
    required this.ayahNum,
    required this.arabic,
    this.transliteration,
    required this.translation,
    required this.subject,
  });

  // Factory to convert SQLite Map to a strongly-typed Model
  factory QuranicDua.fromMap(Map<String, dynamic> map) {
    return QuranicDua(
      id: map['id'] as int,
      surahNum: map['surah_num'] as int,
      ayahNum: map['ayah_num'].toString(),
      arabic: map['arabic'] as String,
      transliteration: map['transliteration'] as String?,
      translation: map['translation'] as String,
      subject: map['subject'] as String,
    );
  }
}
