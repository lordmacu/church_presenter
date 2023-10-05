import 'dart:convert';

import 'package:diacritic/diacritic.dart';
import 'package:ipuc/core/sqlite_helper.dart';

class SongDb {
  final int? id;
  final String title;
  final String youtubeUrl;
  final List<dynamic> paragraphs;
  final String lyricsPlain;
  final List<dynamic> videoExplanation;
  final String searchableText;

  SongDb({
    this.id,
    required this.title,
    required this.youtubeUrl,
    required this.paragraphs,
    required this.lyricsPlain,
    required this.videoExplanation,
    required this.searchableText,
  });

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

    List<SongDb> matchingSongs = List<SongDb>.generate(result.length, (i) {
      return SongDb(
        id: result[i]['id'],
        title: result[i]['title'],
        youtubeUrl: result[i]['youtubeUrl'],
        paragraphs: jsonDecode(result[i]['paragraphs']),
        lyricsPlain: result[i]['lyricsPlain'],
        videoExplanation: jsonDecode(result[i]['videoExplanation']),
        searchableText: result[i]['searchableText'],
      );
    });

    if (matchingSongs.length > 50) {
      matchingSongs = matchingSongs.sublist(matchingSongs.length - 50);
    }

    return matchingSongs;
  }

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

    List<SongDb> first50Songs = List<SongDb>.generate(result.length, (i) {
      return SongDb(
        id: result[i]['id'],
        title: result[i]['title'],
        youtubeUrl: result[i]['youtubeUrl'],
        paragraphs: jsonDecode(result[i]['paragraphs']),
        lyricsPlain: result[i]['lyricsPlain'],
        videoExplanation: jsonDecode(result[i]['videoExplanation']),
        searchableText: result[i]['searchableText'],
      );
    });

    return first50Songs;
  }
}
