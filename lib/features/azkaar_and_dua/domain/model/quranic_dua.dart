class QuranicDua {
  final int id;
  final int? surahNum;
  final String? ayahNum;
  final String arabic;
  final String? transliteration;
  final String translation;
  final String subject;
  final String? source;
  final String categoryType; // 'quranic' or 'witr'

  QuranicDua({
    required this.id,
    this.surahNum,
    this.ayahNum,
    required this.arabic,
    this.transliteration,
    required this.translation,
    required this.subject,
    this.source,
    this.categoryType = 'quranic',
  });

  factory QuranicDua.fromMap(Map<String, dynamic> map, {String categoryType = 'quranic'}) {
    return QuranicDua(
      id: map['id'] as int,
      surahNum: map['surah_num'] as int?,
      ayahNum: map['ayah_num']?.toString(),
      arabic: map['arabic'] as String,
      transliteration: map['transliteration'] as String?,
      translation: map['translation'] as String,
      subject: (map['subject'] as String?) ?? 'Qunoot Supplication',
      source: map['source'] as String?,
      categoryType: categoryType,
    );
  }
}
