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
  final String searchableText; // Campo adicional para ayudar en la búsqueda

  SongDb({
    this.id,
    required this.title,
    required this.youtubeUrl,
    required this.paragraphs,
    required this.lyricsPlain,
    required this.videoExplanation,
    required this.searchableText,
  });

  // Convertir un Map a un objeto Song
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

  // Convertir un objeto Song a un Map
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
    // Obtener la base de datos desde el helper
    final db = await DatabaseHelper().db;

    if (db == null) {
      // Manejar error, tal vez lanzando una excepción o retornando
      return [];
    }

    // Pre-procesamiento único de la consulta
    query = removeDiacritics(query.toLowerCase());

    // Realizar la búsqueda en SQLite
    final List<Map<String, dynamic>> result = await db.query(
      'songs',
      where: 'searchableTitle LIKE ? OR  searchableText LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'id DESC', // Para conseguir los más recientes primero
    );

    // Convertir los resultados a objetos de tipo Song
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

    // Cortar el resultado a las últimas 50 canciones si es necesario
    if (matchingSongs.length > 50) {
      matchingSongs = matchingSongs.sublist(matchingSongs.length - 50);
    }

    // Aquí puedes actualizar cualquier observable o estado que estés usando
    // songsdb.assignAll(matchingSongs);

    return matchingSongs;
  }

  static Future<List<SongDb>> getFirst50Songs() async {
    // Obtener la base de datos desde el helper
    final db = await DatabaseHelper().db;

    if (db == null) {
      // Manejar error, tal vez lanzando una excepción o retornando una lista vacía
      return [];
    }

    // Realizar la consulta en SQLite para obtener las primeras 50 canciones
    final List<Map<String, dynamic>> result = await db.query(
      'songs',
      orderBy: 'id ASC',
      limit: 50, // Limitar a 50 resultados
    );

    // Convertir los resultados a objetos de tipo Song
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

// Resto de tu código de modelo aquí
}
