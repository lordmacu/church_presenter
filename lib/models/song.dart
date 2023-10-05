import 'package:hive/hive.dart';

part 'song.g.dart'; // Nombre del archivo del adaptador generado

@HiveType(typeId: 25)
class Song {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String youtubeUrl;

  @HiveField(2)
  final List<String> paragraphs;
  @HiveField(4)
  final String lyricsPlain;

  @HiveField(3)
  final List<String> videoExplanation;

  Song({
    required this.title,
    required this.youtubeUrl,
    required this.paragraphs,
    required this.videoExplanation,
    required this.lyricsPlain,
  });
}
