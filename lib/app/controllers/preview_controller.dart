import 'package:get/get.dart';

/// `PreviewController` manages the preview of slides and verses.
class PreviewController extends GetxController {
  /// Holds the text of the currently displayed verse.
  var verseText = RxString("");

  /// Holds the data for the current slide being previewed.
  var currentSlide = RxString("");

  /// Holds the path for assets related to the current slide or verse.
  var path = RxString("");
}
