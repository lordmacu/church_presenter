import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fullscreen_window/fullscreen_window.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/home_controller.dart';
import 'package:ipuc/app/controllers/screen_controller.dart';
import 'package:ipuc/core/windows_utils.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_win/video_player_win_plugin.dart';

class ScreenView extends StatelessWidget {
  ScreenView();
  ScreenController _screenController = Get.put(ScreenController());

  String dataTypeMode = "cover";
  String text = "No matarás";

  double getFontSize(String text, double width, double height) {
    int wordCount = text.split(' ').length;

    double minSize = height * 0.05; // 5% de la altura de la pantalla
    double maxSize = height * 0.1; // 10% de la altura de la pantalla

    double factor = (maxSize - minSize) /
        50; // 50 es un conteo de palabras arbitrariamente grande
    double fontSize = maxSize - (factor * wordCount);

    return fontSize.clamp(minSize, maxSize);
  }

  BoxFit getBoxFit() {
    if (_screenController.dataTypeMode.value == "fill") {
      return BoxFit.fill;
    }
    if (_screenController.dataTypeMode.value == "contain") {
      return BoxFit.contain;
    }
    if (_screenController.dataTypeMode.value == "cover") {
      return BoxFit.cover;
    }
    if (_screenController.dataTypeMode.value == "fitWidth") {
      return BoxFit.fitWidth;
    }
    if (_screenController.dataTypeMode.value == "fitHeight") {
      return BoxFit.fitHeight;
    }
    return BoxFit.cover;
  }

  Widget getBackgroundType(context) {
    if (_screenController.dataType == "video") {
      return VideoPlayer(_screenController.videoPlayerController.value);
    }

    if (_screenController.dataType == "image") {
      return ClipRRect(
        child: Image.file(
          File(_screenController.dataTypePath.value),
          fit: getBoxFit(),
        ),
      );
    }
    return ClipRRect(
      child: Image.file(
        File(_screenController.dataTypePath.value),
        fit: getBoxFit(),
      ),
    );
  }

  Widget viewVerse(context) {
    double fontSize = getFontSize(_screenController.verseText.value,
        _screenController.width.value, _screenController.height.value);
    _screenController.fontSize.value = fontSize;

    return Container(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Obx(() => _screenController.dataTypePath.value != ""
              ? getBackgroundType(context)
              : Container()),
          Center(
            child: Container(
              padding: EdgeInsets.all(40),
              child: Obx(
                () => AnimatedSwitcher(
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeIn,
                  duration: Duration(milliseconds: 500),
                  child: Stack(
                    key: ValueKey<String>(_screenController.verseText.value),
                    children: [
                      // Black border
                      Text(
                        _screenController.verseText.value,
                        style: TextStyle(
                          fontSize: _screenController.fontSize.value,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 4
                            ..color = Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // White text
                      Text(
                        _screenController.verseText.value,
                        style: TextStyle(
                          fontSize: _screenController.fontSize.value,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Obx(
            () => _screenController.book.value.length > 0
                ? Positioned(
                    bottom: 10,
                    right: 10,
                    child: Stack(
                      children: [
                        // Black border
                        Text(
                          "${_screenController.book.value} ${_screenController.chapter.value}:${_screenController.verse.value}",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 4
                              ..color = Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // White text
                        Text(
                          "${_screenController.book.value} ${_screenController.chapter.value}:${_screenController.verse.value}",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ))
                : Container(),
          )
        ],
      ),
    );
  }

  Widget viewSong(context) {
    double fontSize = getFontSize(_screenController.paragraph.value,
        _screenController.width.value, _screenController.height.value);
    _screenController.fontSize.value = fontSize;

    return Container(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Obx(() => _screenController.dataTypePath.value != ""
              ? getBackgroundType(context)
              : Container()),
          Center(
            child: Container(
              padding: EdgeInsets.all(40),
              child: Obx(
                () => AnimatedSwitcher(
                  duration: Duration(seconds: 1),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeIn, // Desaparece más rápido
                  child: Stack(
                    key: ValueKey<String>(_screenController.paragraph.value),
                    children: [
                      // Black border
                      Text(
                        _screenController.paragraph.value,
                        style: TextStyle(
                          fontSize: _screenController.fontSize.value,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 4
                            ..color = Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // White text
                      Text(
                        _screenController.paragraph.value,
                        style: TextStyle(
                          fontSize: _screenController.fontSize.value,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget viewTypeSlide(context) {
    if (_screenController.type.value == "verse") {
      return viewVerse(context);
    }
    if (_screenController.type.value == "song") {
      return viewSong(context);
    }
    return Container(
      color: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    _screenController.width.value = width;
    _screenController.height.value = height;

    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      var payload = jsonDecode(call.arguments);

      print(payload);
      if (call.method == "send_viewer") {
        _screenController.type.value = payload["type"];

        if (_screenController.type.value == "verse") {
          _screenController.verseText.value = payload['verseText'];
          _screenController.verse.value = payload['verse'];
          _screenController.chapter.value = payload['chapter'];
          _screenController.book.value = payload['book'];
        }

        if (_screenController.type.value == "song") {
          _screenController.paragraph.value = payload['paragraph'];
        }
      }

      if (call.method == "send_data_type") {
        _screenController.dataTypeMode.value = payload['dataTypeMode'];
        _screenController.dataTypePath.value = payload['dataTypePath'];
        _screenController.dataType.value = payload['dataType'];

        if (_screenController.dataType.value == "video") {
          print("aqu iel mode ${_screenController.dataTypeMode.value}");

          if (_screenController.dataTypeMode.value == "play") {
            _screenController.videoPlayerController.value.play();
          } else if (_screenController.dataTypeMode.value == "pause") {
            _screenController.videoPlayerController.value.pause();
          } else if (_screenController.dataTypeMode.value == "reset") {
            _screenController.videoPlayerController.value
                .seekTo(Duration(seconds: 0));
          } else {
            _screenController.videoPlayerController.value.play();
          }

          var position =
              await _screenController.videoPlayerController.value.position;

          if (payload['dataVideoPath'] !=
              _screenController.dataVideoPath.value) {
            _screenController.dataVideoPath.value = payload['dataVideoPath'];

            _screenController.videoPlayerController.value =
                VideoPlayerController.file(File(payload['dataVideoPath']));
          }

          if (_screenController.dataTypeMode.value == "new") {
            _screenController.videoPlayerController.value
                .initialize()
                .then((value) {
              if (_screenController
                  .videoPlayerController.value.value.isInitialized) {
                _screenController.videoPlayerController.value.setLooping(true);

                _screenController.videoPlayerController.value.setVolume(0.0);

                _screenController.videoPlayerController.value.play();
              } else {
                print("video file load failed");
              }
            });
          }
        }
      }

      return "result";
    });

    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
            backgroundColor: Colors.black,
            body: GestureDetector(
              onTap: () {
                toggleFullScreen();
              },
              child: Obx(() => viewTypeSlide(context)),
            ));
      },
    );
  }
}
