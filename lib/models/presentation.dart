// Import GetX for state management
import 'package:get/get.dart';
// Import Hive for local storage
import 'package:hive/hive.dart';
// Import Slide model
import 'package:ipuc/models/slide.dart';

// Include the generated part for Hive
part 'presentation.g.dart';

/// Represents a presentation containing various details like
/// image, name, date, preacher, topic, and slides.
@HiveType(typeId: 23)
class Presentation {
  // Image associated with the presentation.
  @HiveField(1)
  final String image;

  // Name of the presentation.
  @HiveField(2)
  final String name;

  // Date of the presentation.
  @HiveField(3)
  final DateTime date;

  // Name of the preacher for the presentation.
  @HiveField(4)
  final String preacher;

  // Topic of the presentation.
  @HiveField(5)
  final String topic;

  // Slides associated with the presentation.
  @HiveField(6)
  final RxList<Slide> slides;

  // Unique key for the presentation.
  @HiveField(7)
  final String key;

  /// Constructs a [Presentation] instance with all the required fields.
  ///
  /// All fields are required to instantiate a [Presentation].
  Presentation({
    required this.key,
    required this.image,
    required this.name,
    required this.date,
    required this.preacher,
    required this.topic,
    required this.slides,
  });
}
