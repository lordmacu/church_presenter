// Import Hive for local storage
import 'package:hive/hive.dart';

// Include the generated part for Hive
part 'song.g.dart';

/// Represents a single song with its associated details.
///
/// The class includes properties for the title, YouTube URL, song paragraphs,
/// plain lyrics, and video explanations.
@HiveType(typeId: 25)
class Song {
  // The title of the song.
  @HiveField(0)
  final String title;

  // The YouTube URL for the song.
  @HiveField(1)
  final String youtubeUrl;

  // The paragraphs of the song, typically used for display.
  @HiveField(2)
  final List<String> paragraphs;

  // Plain lyrics of the song for searching or other non-display purposes.
  @HiveField(4)
  final String lyricsPlain;

  // Video explanations associated with the song.
  @HiveField(3)
  final List<String> videoExplanation;

  /// Constructs a [Song] instance with all required fields.
  ///
  /// All fields are required to instantiate a [Song].
  Song({
    required this.title,
    required this.youtubeUrl,
    required this.paragraphs,
    required this.videoExplanation,
    required this.lyricsPlain,
  });
}
