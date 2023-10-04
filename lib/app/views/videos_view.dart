import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/slide_controller.dart';
import 'package:ipuc/widgets/video_widget.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class VideosView extends StatelessWidget {
  final String folderName;
  Function selectImage;
  SliderController controllerSlide = Get.find();

  VideosView({required this.folderName, required this.selectImage});

  Future<List<FileSystemEntity>> getFilesInDirectory() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String docPath = appDocDir.path;
    final directory = Directory('$docPath/$folderName');
    return directory.listSync();
  }

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FileSystemEntity>>(
      future: getFilesInDirectory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final files = snapshot.data!;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.0, // Ajusta esto según tus necesidades
          ),
          itemCount: files.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () async {
                final Uuid uuid = Uuid();

                final directory = await getApplicationDocumentsDirectory();
                final String randomThumbnailName = uuid.v1();
                final thumbnailPath =
                    path.join(directory.path, '$randomThumbnailName.png');
                final seconds = '0:00:01.000000';
                await createThumbnail(
                    files[index].path, thumbnailPath, seconds);

                selectImage(
                  thumbnailPath,
                );
              },
              hoverColor: Colors.transparent,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: VideoWidget(
                    path: files[index].path,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}