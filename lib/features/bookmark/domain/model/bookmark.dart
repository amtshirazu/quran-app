class Bookmark {
  final int? id;
  final int? surahId;
  final int? ayahNumber;
  final int? page; // useful for quick navigation
  final String? note; // user reflection
  final String type; // 'verse' or 'page'
  final DateTime createdAt;

  Bookmark({
    this.id,
    this.surahId,
    this.ayahNumber,
    this.page,
    this.note,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surah_id': surahId,
      'ayah_number': ayahNumber,
      'page': page,
      'note': note,
      'type': type,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
    id: json['id'] as int?,
    surahId: json['surah_id'] as int?,
    ayahNumber: json['ayah_number'] as int?,
    page: json['page'] as int?,
    note: json['note'] as String?,
    type: json['type'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
