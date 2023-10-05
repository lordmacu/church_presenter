import 'dart:math';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:ffmpeg_helper/ffmpeg_helper.dart';

class SliderController extends GetxController {
  var selectedItem = "".obs;
  var image = RxString("");

  var video = RxString("");
  var videoFirstFrame = RxString("");
  FFMpegHelper ffmpeg = FFMpegHelper.instance;
  var selectedOptionImage = "".obs;
  var selectedOptionVideo = "".obs;

  Future<String?> getRandomImage() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String docPath = appDocDir.path;
    final directory = Directory('$docPath/ipucImages');
    final List<FileSystemEntity> files = directory.listSync();

    final imageFiles = files.where((file) {
      return file is File &&
          (file.path.endsWith('.jpg') || file.path.endsWith('.png'));
    }).toList();

    if (imageFiles.isEmpty) {
      return null;
    }

    final random = Random();
    final randomIndex = random.nextInt(imageFiles.length);
    File imageFile = imageFiles[randomIndex] as File;
    return imageFile.path;
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

  Future pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final File savedImage =
          await File(pickedFile.path).copy('${directory.path}/$fileName');

      image.value = savedImage.path;
    }
  }

  Future<void> pickVideo() async {
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      Uuid uuid = const Uuid();
      final String randomVideoName = uuid.v1();
      final String randomThumbnailName = uuid.v1();

      final File savedVideo = await File(pickedFile.path)
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
