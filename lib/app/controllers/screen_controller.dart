import 'dart:io';

import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

/// Controller for managing screen-related state.
class ScreenController extends GetxController {
  // Observable variables
  var verse = 0.obs;
  var book = "".obs;
  var chapter = 0.obs;
  var verseText = "".obs;
  var type = "verse".obs;
  var dataTypeMode = "".obs;
  var fontSize = 10.0.obs;
  var dataTypePath = "".obs;
  var dataVideoPath = "".obs;

  var dataType = "".obs;
  var paragraph = "".obs;
  var width = 0.0.obs;
  var height = 0.0.obs;
  var payload = {}.obs;

  late VideoPlayerController videoPlayerController;


  /// Disposes the VideoPlayerController when the screen is closed.
  @override
  void onClose() {
    videoPlayerController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

  }

  Future<void> initializeVideoPlayerFromFile(File videoFile) async {
    videoPlayerController = VideoPlayerController.file(videoFile);
     update();
  }

  Future<void> initializeVideoPlayer() async {
    videoPlayerController
        .initialize()
        .then((value)  {
      if (
          videoPlayerController.value.isInitialized) {
        videoPlayerController.setLooping(true);

        videoPlayerController.setVolume(0.0);
        videoPlayerController.play();
        update();
      } else {}
    });

  }

  /// Pauses the video and updates the state.
  ///
  /// @return {Future<void>}
  Future<void> pause() async {
    await videoPlayerController.pause();
    update();
  }

  Future<void> disposeVideo() async {
    await videoPlayerController.dispose();
    update();
  }
}
