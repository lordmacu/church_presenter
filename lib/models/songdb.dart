import 'dart:convert';
import 'package:diacritic/diacritic.dart';
import 'package:ipuc/core/sqlite_helper.dart';

/// Represents a song in the database.
///
/// The class includes properties for ID, title, YouTube URL, song paragraphs,
/// plain lyrics, video explanations, and searchable text.
class SongDb {
  final int? id;
  final String title;
  final String youtubeUrl;
  final List<dynamic> paragraphs;
  final String lyricsPlain;
  final List<dynamic> videoExplanation;
  final String searchableText;

  /// Constructs a [SongDb] instance with all required fields.
  ///
  /// All fields are required except the ID, which can be null.
  SongDb({
    this.id,
    required this.title,
    required this.youtubeUrl,
    required this.paragraphs,
    required this.lyricsPlain,
    required this.videoExplanation,
    required this.searchableText,
  });

  /// Creates a [SongDb] instance from a [Map].
  factory SongDb.fromMap(Map<String, dynamic> map) {
    return SongDb(
      id: map['id'],
      title: map['title'],
      youtubeUrl: map['youtubeUrl'],
      paragraphs: List<String>.from(jsonDecode(map['paragraphs'])),
      lyricsPlain: map['lyricsPlain'],
      videoExplanation: List<String>.from(jsonDecode(map['videoExplanation'])),
      searchableText: map['searchableText'],
    );
  }

  /// Converts the [SongDb] instance to a [Map].
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'youtubeUrl': youtubeUrl,
      'paragraphs': jsonEncode(paragraphs),
      'lyricsPlain': lyricsPlain,
      'videoExplanation': jsonEncode(videoExplanation),
      'searchableText': searchableText,
    };
  }

  /// Searches songs based on the given query string.
  ///
  /// The method performs a case-insensitive search and removes diacritics.
  /// Returns a list of [SongDb] instances that match the query.
  static Future<List<SongDb>> searchSongs(String query) async {
    final db = await DatabaseHelper().db;

    if (db == null) {
      return [];
    }

    query = removeDiacritics(query.toLowerCase());
    final List<Map<String, dynamic>> result = await db.query(
      'songs',
      where: 'searchableTitle LIKE ? OR  searchableText LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'id DESC',
    );

    // Convert query results to List of SongDb instances
    var matchingSongs =
        List.generate(result.length, (i) => SongDb.fromMap(result[i]));

    if (matchingSongs.length > 50) {
      matchingSongs = matchingSongs.sublist(matchingSongs.length - 50);
    }

    return matchingSongs;
  }

  /// Fetches the first 50 songs from the database.
  ///
  /// Returns a list of [SongDb] instances.
  static Future<List<SongDb>> getFirst50Songs() async {
    final db = await DatabaseHelper().db;

    if (db == null) {
      return [];
    }

    final List<Map<String, dynamic>> result = await db.query(
      'songs',
      orderBy: 'id ASC',
      limit: 50,
    );

    // Convert query results to List of SongDb instances
    return List.generate(result.length, (i) => SongDb.fromMap(result[i]));
  }
}
