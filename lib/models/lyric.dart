// Import necessary packages
import 'package:hive/hive.dart';
import 'package:ipuc/models/paragraph.dart';

// Include generated part
part 'lyric.g.dart';

/// Represents a lyric which is a collection of paragraphs.
@HiveType(typeId: 21)
class Lyric {
  // A list of paragraphs that make up the lyric.
  @HiveField(0)
  final List<Paragraph> paragraphs;

  /// Constructs a [Lyric] instance from a list of [Paragraph]s.
  ///
  /// The [paragraphs] parameter must be provided.
  Lyric({required this.paragraphs});
}
