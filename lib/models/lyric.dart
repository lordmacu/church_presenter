import 'package:hive/hive.dart';
import 'package:ipuc/models/paragraph.dart';

part 'lyric.g.dart';

@HiveType(typeId: 21)
class Lyric {
  @HiveField(0)
  final List<Paragraph> paragraphs;

  Lyric({required this.paragraphs});
}
