import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fullscreen_window/fullscreen_window.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/home_controller.dart';
import 'package:ipuc/app/controllers/screen_controller.dart';
import 'package:ipuc/core/windows_utils.dart';

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

  Widget viewVerse() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 5,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Obx(() => _screenController.dataTypePath.value != ""
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(_screenController.dataTypePath.value),
                    fit: getBoxFit(),
                  ),
                )
              : Container()),
          Center(
            child: Container(
                padding: EdgeInsets.all(40),
                child: Obx(
                  () => Stack(
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
                )),
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

  Widget viewTypeSlide() {
    if (_screenController.type.value == "verse") {
      return viewVerse();
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double fontSize = getFontSize(text, width, height);

    _screenController.fontSize.value = fontSize;

    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      var payload = jsonDecode(call.arguments);
      _screenController.type.value = payload["type"];
      if (call.method == "send_verse") {
        _screenController.verseText.value = payload["verse"];
      }
      if (call.method == "send_viewer") {
        if (_screenController.type.value == "verse") {
          _screenController.verseText.value = payload['verseText'];
          _screenController.verse.value = payload['verse'];
          _screenController.chapter.value = payload['chapter'];
          _screenController.book.value = payload['book'];
        }
      }

      if (call.method == "send_data_type") {
        _screenController.dataTypeMode.value = payload['dataTypeMode'];
        _screenController.dataTypePath.value = payload['dataTypePath'];
      }

      return "result";
    });

    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
            body: GestureDetector(
          onTap: () {
            toggleFullScreen();
          },
          child: Obx(() => viewTypeSlide()),
        ));
      },
    );
  }
}
