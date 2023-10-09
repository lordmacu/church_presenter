import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/slide_controller.dart';
import 'package:ipuc/widgets/video_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class VideosView extends StatelessWidget {
  final String folderName;
  final Function selectImage;
  final SliderController controllerSlide = Get.find();

  VideosView({Key? key, required this.folderName, required this.selectImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Utilize the controller to fetch the files in the specified directory.
    return FutureBuilder<List<FileSystemEntity>>(
      future: controllerSlide.getFilesInDirectory(folderName),
      builder: (context, snapshot) {
        // Show a loading indicator while waiting for the future to complete.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        // Display any errors that occur while fetching files.
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final files = snapshot.data!;

        // Build a grid view of the video files.
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.0,
          ),
          itemCount: files.length,
          itemBuilder: (context, index) {
            return InkWell(
              // When a video file is tapped, create a thumbnail and trigger selectImage.
              onTap: () async {
                Uuid uuid = const Uuid();

                final directory = await getApplicationDocumentsDirectory();
                final String randomThumbnailName = uuid.v1();
                final thumbnailPath =
                    path.join(directory.path, '$randomThumbnailName.png');
                const seconds = '0:00:01.000000';

                await controllerSlide.createThumbnail(
                    files[index].path, thumbnailPath, seconds);

                selectImage(thumbnailPath, files[index].path);
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
