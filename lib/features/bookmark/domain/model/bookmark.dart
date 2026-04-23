class Bookmark {
  final int? id;
  final int surahId;
  final int? ayahNumber;
  final int? page; // useful for quick navigation
  final String? note; // user reflection
  final DateTime createdAt;

  Bookmark({
    this.id,
    required this.surahId,
    required this.ayahNumber,
    this.page,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surah_id': surahId,
      'ayah_number': ayahNumber,
      'page': page,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
    id: json['id'] as int?,
    surahId: json['surah_id'] as int,
    ayahNumber: json['ayah_number'] as int,
    page: json['page'] as int?,
    note: json['note'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
