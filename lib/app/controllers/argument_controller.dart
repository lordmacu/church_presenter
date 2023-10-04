import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:get/get.dart';

class ArgumentController extends GetxController {
  WindowController? _windowController;
  Map? _args;
  int? _windowId;

  // Getter for windowController
  WindowController? get windowController => _windowController;

  // Getter for args
  Map? get args => _args;

  // Getter for windowId
  int? get windowId => _windowId;

  void setArguments(WindowController controller, Map arguments, int windowId) {
    _windowController = controller;
    _args = arguments;
    _windowId = windowId;
    update();
  }
}
