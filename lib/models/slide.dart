// Import Hive for local storage
import 'package:hive/hive.dart';

// Include the generated part for Hive
part 'slide.g.dart';

/// Represents a single slide within a presentation.
/// Each slide has a unique key, type, and associated data.
@HiveType(typeId: 24)
class Slide {
  // Unique key for identifying the slide.
  @HiveField(0)
  final String key;

  // Type of the slide (e.g., "text", "image", etc.).
  @HiveField(1)
  final String type;

  // Data type of the slide content (e.g., "string", "path", etc.).
  @HiveField(2)
  final String dataType;

  // JSON representation of the slide content.
  @HiveField(3)
  final String json;

  // Path associated with the dataType (could be file path, URL, etc.).
  @HiveField(4)
  final String dataTypePath;

  // Mode associated with the dataType (could be read mode, write mode, etc.).
  @HiveField(5)
  final String dataTypeMode;

  /// Constructs a [Slide] instance with all the required fields.
  ///
  /// All fields are required to instantiate a [Slide].
  Slide({
    required this.key,
    required this.type,
    required this.dataType,
    required this.dataTypePath,
    required this.json,
    required this.dataTypeMode,
  });
}
