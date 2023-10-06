import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:get/get.dart';

/// `ArgumentController` manages the state related to window arguments.
/// This class holds a reference to the window controller, arguments map, and window ID.
class ArgumentController extends GetxController {
  /// Holds the value of the window controller.
  WindowController? _windowController;

  /// Holds the value of the arguments map.
  Map? _args;

  /// Holds the value of the window ID.
  int? _windowId;

  /// Getter for the window controller.
  WindowController? get windowController => _windowController;

  /// Getter for the arguments map.
  Map? get args => _args;

  /// Getter for the window ID.
  int? get windowId => _windowId;

  /// Sets the arguments and related window data.
  ///
  /// - [controller] is the window controller.
  /// - [arguments] is the arguments map.
  /// - [windowId] is the window ID.
  void setArguments(WindowController controller, Map arguments, int windowId) {
    _windowController = controller;
    _args = arguments;
    _windowId = windowId;
    update(); // Notify listeners to rebuild
  }
}
