import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class VideoWidget extends StatefulWidget {
  final String path;

  const VideoWidget({Key? key, required this.path}) : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  String finalPath = "";

  Future<String?> createThumbnail(
      String videoPath, String outputPath, String seconds) async {
    final programFilesPath = Platform.environment['ProgramFiles'];
    final ffmpegPath = '$programFilesPath\\ipuc\\ffmpeg';
    try {
      final processResult = await Process.run(
        ffmpegPath + '\\bin\\ffmpeg.exe',
        [
          '-i',
          videoPath,
          '-y',
          '-ss',
          seconds,
          '-frames:v',
          '1',
          '-q:v',
          '1',
          outputPath,
        ],
      );

      if (processResult.exitCode == 0) {
        return outputPath;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future createVideoUrl() async {
    Uuid uuid = const Uuid();

    final directory = await getApplicationDocumentsDirectory();
    final String randomThumbnailName = uuid.v1();
    final thumbnailPath = path.join(directory.path, '$randomThumbnailName.png');
    const seconds = '0:00:01.000000';
    await createThumbnail(widget.path, thumbnailPath, seconds);
    setState(() {
      finalPath = thumbnailPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: finalPath != ""
          ? Image.file(File(finalPath))
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void initState() {
    super.initState();
    createVideoUrl();
  }
}
