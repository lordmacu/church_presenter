import 'package:hive/hive.dart';
part 'verse.g.dart'; // Nombre del archivo del adaptador generado

// Para Verse
@HiveType(typeId: 27)
class Verse {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int bookId;

  @HiveField(2)
  final int chapter;

  @HiveField(3)
  final int verse;

  @HiveField(4)
  final String text;

  @HiveField(5)
  final String version;

  Verse({
    required this.id,
    required this.bookId,
    required this.version,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  factory Verse.fromMap(Map<dynamic, dynamic> map) {
    return Verse(
      id: map['id'],
      bookId: map['book_id'],
      version: map['version'],
      chapter: map['chapter'],
      verse: map['verse'],
      text: map['text'],
    );
  }
}
