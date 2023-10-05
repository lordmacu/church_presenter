import 'package:hive/hive.dart';

part 'paragraph.g.dart'; // Nombre del archivo del adaptador generado

// paragraph.dart
@HiveType(typeId: 22)
class Paragraph {
  @HiveField(0)
  final String lines;

  Paragraph({required this.lines});
}
