import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class VideoController extends GetxController {
  var videoPath = "".obs;

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
    createThumbnail(videoPath.value, thumbnailPath, seconds);
  }

  @override
  void onInit() {
    super.onInit();

    createVideoUrl();
  }
}
