

class PageGlyph {
  final int page;
  final String content;
  final List<int> surahNumbers;

  PageGlyph({required this.page, required this.content, required this.surahNumbers});

  factory PageGlyph.fromJson(Map<String, dynamic> json) {

    return PageGlyph(
      page: json['page'],
      content: json['content'],
      surahNumbers: List<int>.from(json['surahNumbers'] ?? []),
    );
  }
}
