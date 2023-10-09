// Import Hive package for local storage
import 'package:hive/hive.dart';

// Include generated part for Hive
part 'paragraph.g.dart';

/// Represents a paragraph containing lines of text.
@HiveType(typeId: 22)
class Paragraph {
  // The lines that make up the paragraph.
  @HiveField(0)
  final String lines;

  /// Constructs a [Paragraph] instance from a given set of lines.
  ///
  /// The [lines] parameter is required to instantiate a [Paragraph].
  Paragraph({required this.lines});
}
