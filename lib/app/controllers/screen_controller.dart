import 'package:get/get.dart';

class ScreenController extends GetxController {
  var verse = 0.obs;
  var book = "".obs;
  var chapter = 0.obs;
  var verseText = "".obs;
  var dataTypeMode = "".obs;
  var dataTypePath = "".obs;
  var payload = ({} as Map<dynamic, dynamic>).obs;
}
