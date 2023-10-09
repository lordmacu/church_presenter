import 'package:hive/hive.dart';

// Generates the adapter code with hive_generator
part 'book.g.dart';

// Annotate with Hive metadata for type ID
@HiveType(typeId: 20)
class Book {
  // Declare Hive fields
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int testamentId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String abbrevation;

  // Constructor for the Book class
  Book({
    required this.id,
    required this.testamentId,
    required this.name,
    required this.abbrevation,
  });

  // Factory constructor to initialize from a Map
  factory Book.fromMap(Map<dynamic, dynamic> map) {
    return Book(
      id: map['id'],
      testamentId: map['testament_id'],
      name: map['name'],
      abbrevation: map['abbreviation'],
    );
  }
}
