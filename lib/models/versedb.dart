class VerseDb {
  final int? id;
  final int? bookId;
  final int? chapter;
  final int? verse;
  final String? text;
  final String? version;

  VerseDb(
      {this.id,
      required this.bookId,
      required this.chapter,
      required this.verse,
      required this.text,
      required this.version});

  // Convertir un Map a un objeto Song
  factory VerseDb.fromMap(Map<String, dynamic> map) {
    return VerseDb(
        id: map['id'],
        bookId: map['book_id'],
        chapter: map['chapter'],
        verse: map['verse'],
        text: map['text'],
        version: map['version']);
  }

  // Convertir un objeto Song a un Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'chapter': chapter,
      'verse': verse,
      'text': text,
      'version': version,
    };
  }
}
