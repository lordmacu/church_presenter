import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/video_controller.dart';
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
  VideoController controller = Get.put(VideoController());

  Future createVideoUrl() async {
    Uuid uuid = const Uuid();

    final directory = await getApplicationDocumentsDirectory();
    final String randomThumbnailName = uuid.v1();
    final thumbnailPath = path.join(directory.path, '$randomThumbnailName.png');
    const seconds = '0:00:01.000000';
    await controller.createThumbnail(widget.path, thumbnailPath, seconds);
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
