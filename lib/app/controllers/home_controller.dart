import 'package:get/get.dart';

class HomeController extends GetxController {
  var counter = 0;

  void increment() {
    counter++;
    update();
  }
}
