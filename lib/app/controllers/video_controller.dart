import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// `VideoController` is responsible for video-related functionalities such as creating thumbnails.
class VideoController extends GetxController {
  // Observable to hold the path of the video.
  var videoPath = "".obs;

  /// Creates a thumbnail for a given video.
  ///
  /// @param videoPath - The path of the video file.
  /// @param outputPath - The path where the thumbnail should be saved.
  /// @param seconds - The time in the video to capture the thumbnail.
  /// @return Future<String?> - The path of the created thumbnail or null.
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

  /// Creates a URL for the video thumbnail and stores it.
  Future createVideoUrl() async {
    Uuid uuid = const Uuid();
    final directory = await getApplicationDocumentsDirectory();
    final String randomThumbnailName = uuid.v1();
    final thumbnailPath = path.join(directory.path, '$randomThumbnailName.png');
    const seconds = '0:00:01.000000';
    createThumbnail(videoPath.value, thumbnailPath, seconds);
  }

  /// Overrides the `onInit` lifecycle method to create a video URL when the controller is initialized.
  @override
  void onInit() {
    super.onInit();
    createVideoUrl();
  }
}
