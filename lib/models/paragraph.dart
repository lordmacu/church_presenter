import 'package:hive/hive.dart';

part 'paragraph.g.dart';

@HiveType(typeId: 22)
class Paragraph {
  @HiveField(0)
  final String lines;

  Paragraph({required this.lines});
}
