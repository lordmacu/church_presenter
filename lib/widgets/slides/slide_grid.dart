import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:ipuc/app/controllers/argument_controller.dart';
import 'package:ipuc/app/controllers/present_controller.dart';
import 'package:ipuc/app/controllers/preview_controller.dart';
import 'package:ipuc/app/controllers/slide_controller.dart';
import 'package:get/get.dart';
import 'package:ipuc/models/slide.dart';
import 'package:ipuc/widgets/live_output/preview.dart';
import 'package:localization/localization.dart';

class SlideGrid extends StatelessWidget {
  SlideGrid({Key? key}) : super(key: key);
  final SliderController controller = Get.find();
  final ScrollController slideController = ScrollController();
  final ArgumentController argumentController = Get.find();
  final PresentController presentController = Get.find();
  final PreviewController previewController = Get.find();

  final FocusNode focusNode = FocusNode();

  sendToViewer(Slide slide) async {
    try {
      final subWindowIds = await DesktopMultiWindow.getAllSubWindowIds();

      var jsonData = jsonDecode(slide.json);
      var videoPath = "";

      if (jsonData["videoPath"] != null && jsonData["videoPath"] is String) {
        videoPath = jsonData["videoPath"];
      }

      final payloaDataType = jsonEncode({
        "dataType": slide.dataType,
        "dataTypePath": slide.dataTypePath,
        "dataTypeMode": slide.dataType == "video" ? "new" : slide.dataTypeMode,
        "dataVideoPath": videoPath,
      });
      await DesktopMultiWindow.invokeMethod(
          subWindowIds[0], "send_data_type", payloaDataType);

      await Future.delayed(const Duration(milliseconds: 50));

      await DesktopMultiWindow.invokeMethod(
          subWindowIds[0], "send_viewer", slide.json);
    } catch (e) {
      //catch errors
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    int crossAxisCount = 3;
    double desiredItemHeight = 350.0;
    double childAspectRatio = width / (crossAxisCount * desiredItemHeight);

    return Obx(
        () => presentController.selectedPresentation.value.slides.isNotEmpty
            ? GridView.builder(
                controller: slideController,
                itemCount: presentController
                    .selectedPresentation.value.slides.reversed
                    .toList()
                    .length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                ),
                itemBuilder: (context, index) {
                  Slide slide = presentController
                      .selectedPresentation.value.slides[index];
                  return Obx(() => PreviewWidget(
                      index: index,
                      keyItem: slide.key,
                      type: slide.type,
                      isSelected: controller.selectedItem.value == slide.key,
                      json: slide.json,
                      dataType: slide.dataType,
                      dataTypeMode: slide.dataTypeMode,
                      dataTypePath: slide.dataTypePath,
                      onTap: () async {
                        controller.selectedItem.value = slide.key;
                        previewController.currentSlide.value = slide.json;
                        controller.selectedOptionImage.value =
                            slide.dataTypeMode;

                        presentController.selectedSlide.value = Slide(
                            key: slide.key,
                            type: slide.type,
                            dataType: slide.dataType,
                            dataTypePath: slide.dataTypePath,
                            dataTypeMode: slide.dataTypeMode,
                            json: slide.json);

                        try {
                          await presentController.getAllSubWindowIds();
                        } catch (e) {
                          await presentController.createNewWindow();
                        }
                        sendToViewer(presentController.selectedSlide.value);
                      }));
                },
              )
            : Center(
                child: Text(
                  'add_song_or_verse'.i18n(),
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ));
  }
}
