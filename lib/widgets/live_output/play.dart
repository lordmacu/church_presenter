import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fullscreen_window/fullscreen_window.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/slide_controller.dart';
import 'package:ipuc/app/views/screen_view.dart';
import 'package:ipuc/widgets/progress_bar_with_text.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:multi_window/multi_window.dart';

class PlayWidget extends StatelessWidget {
  final SliderController controller = Get.find();
  MultiWindow? secondaryWindow;
  final SliderController controllerSlide = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () async {
                  final size = Size(300, 300);
                  final window =
                      await DesktopMultiWindow.createWindow(jsonEncode({
                    'args1': 'Sub window',
                    'args2': 100,
                    'args3': true,
                    'bussiness': 'bussiness_test',
                  }));
                  window
                    ..setFrame(const Offset(0, 0) & const Size(1280, 720))
                    ..setTitle("")
                    ..center()
                    ..show();

                  String? image = await controllerSlide.getRandomImage();

                  final payloaDataType = jsonEncode({
                    "dataType": "image",
                    "dataTypePath": "${image!}",
                    "dataTypeMode": "cover"
                  });
                  final subWindowIds =
                      await DesktopMultiWindow.getAllSubWindowIds();

                  final setDataType = await DesktopMultiWindow.invokeMethod(
                      subWindowIds[0], "send_data_type", payloaDataType);
                },
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20.0,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  /*controller.selectedItem.value =
                      controller.selectedItem.value - 1;*/
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  /*  controller.selectedItem.value =
                      controller.selectedItem.value + 1;*/
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
