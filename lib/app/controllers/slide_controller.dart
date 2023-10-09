import 'dart:io';
import 'dart:math';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:ffmpeg_helper/ffmpeg_helper.dart';

/// `SliderController` is responsible for managing the state related to slides,
/// images, and videos in the application.
class SliderController extends GetxController {
  // Observables to hold the selected items, images, and videos.
  var selectedItem = "".obs;
  var image = RxString("");
  var video = RxString("");
  var videoFirstFrame = RxString("");

  // Instance of FFMPeg helper.
  FFMpegHelper ffmpeg = FFMpegHelper.instance;

  // Observables to hold selected options for image and video.
  var selectedOptionImage = "".obs;
  var selectedOptionVideo = "".obs;

  /// Randomly selects an image from the application's document directory.
  ///
  /// @returns Future<String?> - The path to the randomly selected image or `null` if no image is found.
  Future<String?> getRandomImage() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final directory = Directory('${appDocDir.path}/ipucImages');
    final List<FileSystemEntity> files = directory.listSync();

    // Filter out non-image files
    final imageFiles = files
        .where((file) =>
            file is File &&
            (file.path.endsWith('.jpg') || file.path.endsWith('.png')))
        .toList();

    if (imageFiles.isEmpty) {
      return null;
    }

    final random = Random();
    final randomIndex = random.nextInt(imageFiles.length);
    File imageFile = imageFiles[randomIndex] as File;
    return imageFile.path;
  }

  /// Generates a thumbnail for a video at a specified time.
  ///
  /// @param videoPath - The path of the video file.
  /// @param outputPath - The path to save the thumbnail.
  /// @param seconds - The timecode of the frame to use for the thumbnail.
  /// @returns Future<String?> - The path to the thumbnail or `null` if thumbnail generation failed.
  Future<String?> createThumbnail(
      String videoPath, String outputPath, String seconds) async {
    try {
      final processResult = await Process.run(
        'ffmpeg',
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
          outputPath
        ],
      );
      return processResult.exitCode == 0 ? outputPath : null;
    } catch (e) {
      return null;
    }
  }

  Future<List<FileSystemEntity>> getFilesInDirectory(folderName) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String docPath = appDocDir.path;
    final directory = Directory('$docPath/$folderName');
    return directory.listSync();
  }

  Future<String?> createThumbnailFile(
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

  /// Picks an image from the device gallery and saves it to the application's document directory.
  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final savedImage =
          await File(pickedFile.path).copy('${directory.path}/$fileName');
      image.value = savedImage.path;
    }
  }

  /// Picks a video from the device gallery, saves it, and generates a thumbnail.
  Future<void> pickVideo() async {
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final Uuid uuid = Uuid();
      final randomVideoName = uuid.v1();
      final randomThumbnailName = uuid.v1();
      final savedVideo = await File(pickedFile.path)
          .copy('${directory.path}/$randomVideoName.mp4');
      video.value = savedVideo.path;
      final thumbnailPath =
          path.join(directory.path, '$randomThumbnailName.png');
      const seconds = '0:00:01.000000';
      final generatedThumbnailPath =
          await createThumbnail(savedVideo.path, thumbnailPath, seconds);
      videoFirstFrame.value = generatedThumbnailPath!;
    }
  }
}
