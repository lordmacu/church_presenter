/// Represents a Bible verse in the database.
///
/// The class includes properties for ID, book ID, chapter, verse, text, and version.
class VerseDb {
  final int? id;
  final int? bookId;
  final int? chapter;
  final int? verse;
  final String? text;
  final String? version;

  /// Constructs a [VerseDb] instance with all required fields.
  ///
  /// All fields are nullable except for bookId, chapter, verse, text, and version,
  /// which are required.
  VerseDb({
    this.id,
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.version,
  });

  /// Creates a [VerseDb] instance from a [Map].
  ///
  /// The keys in the map should match the field names of the [VerseDb] class.
  factory VerseDb.fromMap(Map<String, dynamic> map) {
    return VerseDb(
      id: map['id'],
      bookId: map['book_id'],
      chapter: map['chapter'],
      verse: map['verse'],
      text: map['text'],
      version: map['version'],
    );
  }

  /// Converts the [VerseDb] instance to a [Map].
  ///
  /// The keys in the map will match the field names of the [VerseDb] class.
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
