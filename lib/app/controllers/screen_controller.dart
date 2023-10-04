import 'package:get/get.dart';

class ScreenController extends GetxController {
  var verse = 0.obs;
  var book = "".obs;
  var chapter = 0.obs;
  var verseText = "".obs;
  var type = "verse".obs;
  var dataTypeMode = "".obs;
  var fontSize = 10.0.obs;
  var dataTypePath = "".obs;
  var paragraph = "".obs;
  var width = 0.0.obs;
  var height = 0.0.obs;
  var payload = ({} as Map<dynamic, dynamic>).obs;
}
