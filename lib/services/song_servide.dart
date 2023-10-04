import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:hive_flutter/adapters.dart';
import 'package:ipuc/core/sqlite_helper.dart';
import 'package:ipuc/models/lyric.dart';
import 'package:ipuc/models/paragraph.dart';
import 'package:ipuc/models/song.dart';
import 'package:ipuc/models/video_explanation.dart';

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:diacritic/diacritic.dart'; // para removeDiacritics

class SongService {
  Box? _songs;

  Future<void> initSongs() async {
    try {
      await Hive.initFlutter();
      // Registra otros adaptadores

      if (_songs == null || !_songs!.isOpen) {
        _songs = await Hive.openBox('songs');
      }

      if (_songs!.isEmpty) {
        await initializeDatabase();
        await initializeDatabaseJson('lib/assets/songs1.json');
        await initializeDatabaseJson('lib/assets/songs2.json');
        await initializeDatabaseJson('lib/assets/songs3.json');
      }
    } catch (e) {
    } finally {
      await _songs!.close();
    }
  }

  Future<void> initializeDatabase() async {
    final ipucDb = await DatabaseHelper().db;

    if (ipucDb == null) {
      return;
    }

    await Hive.initFlutter();

    String jsonString = await rootBundle.loadString('lib/assets/songs.json');
    List<dynamic> jsonList = jsonDecode(jsonString);

    for (var song in jsonList) {
      List<String> paragraphs = [];

      for (var lyric in song["lyrics"]) {
        List<String> line = [];

        for (var paragraph in lyric) {
          line.add(paragraph);
        }
        paragraphs.add(line.join("\n"));
      }

      List<String> paragraphsExplation = [];

      for (var lyric in song["videoExplanation"]) {
        for (var paragraph in lyric) {
          paragraphsExplation.add(paragraph);
        }
      }

      // Limpiar el título aquí
      String cleanTitle = song["title"];
      cleanTitle = cleanTitle.replaceFirst("Letra ", "");
      cleanTitle = cleanTitle.replaceFirst("Letra de ", "");

      // Create a search text field
      String searchableText = removeDiacritics(
          (cleanTitle + " " + paragraphs.join(" ")).replaceAll('\n', ' '));

      await ipucDb.insert('songs', {
        'title': cleanTitle, // Use the cleaned title here
        'youtubeUrl': song["youtubeUrl"],
        'paragraphs': jsonEncode(paragraphs),
        'lyricsPlain': jsonEncode(song["lyrics"]),
        'videoExplanation': jsonEncode(paragraphsExplation),
        'searchableText': searchableText // Insert the searchable text here
      });
    }
  }

  Future<void> initializeDatabaseJson(url) async {
    final ipucDb = await DatabaseHelper().db;

    if (ipucDb == null) {
      return;
    }

    String jsonString = await rootBundle.loadString(url);
    List<dynamic> jsonList = jsonDecode(jsonString);

    for (var song in jsonList) {
      List<String> paragraphs = [];

      for (var lyric in song["lyrics"]) {
        paragraphs.add(lyric);
      }

      // Clean the title here
      String cleanTitle = song["title"];
      cleanTitle = cleanTitle.replaceFirst("LETRA", "").trim();
      cleanTitle = cleanTitle.replaceFirst("Letra", "").trim();
      cleanTitle = cleanTitle.replaceFirst("letra", "").trim();

      // Create a search text field
      String searchableText = removeDiacritics(
          (cleanTitle + " " + paragraphs.join(" ")).replaceAll('\n', ' '));

      await ipucDb.insert('songs', {
        'title': cleanTitle, // Use the cleaned title here
        'youtubeUrl': song["youtubeUrl"],
        'paragraphs': jsonEncode(paragraphs),
        'lyricsPlain': jsonEncode(song["lyrics"]),
        'videoExplanation': jsonEncode([]),
        'searchableText': searchableText // Insert the searchable text here
      });
    }
  }
}
