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

  late Rx<VideoPlayerController> videoPlayerController =
      VideoPlayerController.networkUrl(Uri()).obs;

  /// Disposes the VideoPlayerController when the screen is closed.
  @override
  void onClose() {
    videoPlayerController.value.dispose();
    super.onClose();
  }

  /// Pauses the video and updates the state.
  ///
  /// @return {Future<void>}
  Future<void> pause() async {
    await videoPlayerController.value.pause();
    update();
  }
}
