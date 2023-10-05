import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:get/get.dart';

class ArgumentController extends GetxController {
  WindowController? _windowController;
  Map? _args;
  int? _windowId;

  WindowController? get windowController => _windowController;

  Map? get args => _args;

  int? get windowId => _windowId;

  void setArguments(WindowController controller, Map arguments, int windowId) {
    _windowController = controller;
    _args = arguments;
    _windowId = windowId;
    update();
  }
}
