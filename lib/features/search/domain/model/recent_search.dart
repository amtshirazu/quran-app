class RecentSearch {
  final int? id;
  final String query;
  final int timestamp;

  const RecentSearch({
    this.id,
    required this.query,
    required this.timestamp,
  });

  factory RecentSearch.fromMap(Map<String, dynamic> map) {
    return RecentSearch(
      id: map['id'] as int?,
      query: map['query'] as String,
      timestamp: map['timestamp'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'query': query,
      'timestamp': timestamp,
    };
  }
}
