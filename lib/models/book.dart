import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 20)
class Book {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int testamentId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String abbrevation;

  Book({
    required this.id,
    required this.testamentId,
    required this.name,
    required this.abbrevation,
  });

  factory Book.fromMap(Map<dynamic, dynamic> map) {
    return Book(
      id: map['id'],
      testamentId: map['testament_id'],
      name: map['name'],
      abbrevation: map['abbreviation'],
    );
  }
}
