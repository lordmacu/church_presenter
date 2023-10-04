import 'package:hive/hive.dart';
import 'package:ipuc/models/paragraph.dart';
part 'video_explanation.g.dart'; // Nombre del archivo del adaptador generado

// video_explanation.dart
@HiveType(typeId: 28)
class VideoExplanation {
  @HiveField(0)
  final List<Paragraph> explanations;

  VideoExplanation({required this.explanations});
}
