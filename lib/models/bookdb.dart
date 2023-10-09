/// Represents a book entry in the database.
class BookDb {
  // Declare fields for book information
  final int? id;
  final String testamentId;
  final String name;
  final String abbrevation;

  /// Constructor for initializing a `BookDb` instance.
  ///
  /// The `id` field is optional, and other fields are required.
  BookDb({
    this.id,
    required this.testamentId,
    required this.name,
    required this.abbrevation,
  });

  /// Factory constructor to create a `BookDb` instance from a map.
  ///
  /// This constructor is useful for initializing instances
  /// from database query results.
  factory BookDb.fromMap(Map<String, dynamic> map) {
    return BookDb(
      id: map['id'],
      testamentId: map['testament_id'],
      name: map['name'],
      abbrevation: map['abbrevation'],
    );
  }

  /// Convert the `BookDb` instance into a map.
  ///
  /// This function is useful for database insert or update operations.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'testamentId': testamentId,
      'name': name,
      'abbrevation': abbrevation,
    };
  }
}
