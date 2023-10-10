import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/present_controller.dart';
import 'package:ipuc/app/controllers/preview_controller.dart';
import 'package:localization/localization.dart';

class PreviewWidget extends StatelessWidget {
  final String type;
  final String keyItem;
  final String json;
  final String dataType;
  final String dataTypeMode;
  final String dataTypePath;
  final bool isSelected;
  final Function onTap;
  final int index;

  final PreviewController previewController = Get.put(PreviewController());
  final PresentController presentController = Get.find();

  PreviewWidget({
    Key? key,
    required this.type,
    required this.isSelected,
    required this.onTap,
    required this.json,
    required this.index,
    required this.dataType,
    required this.dataTypePath,
    required this.dataTypeMode,
    required this.keyItem,
  }) : super(key: key);

  BoxFit getBoxFit() {
    if (dataTypeMode == "fill") {
      return BoxFit.fill;
    }
    if (dataTypeMode == "contain") {
      return BoxFit.contain;
    }
    if (dataTypeMode == "cover") {
      return BoxFit.cover;
    }
    if (dataTypeMode == "fitWidth") {
      return BoxFit.fitWidth;
    }
    if (dataTypeMode == "fitHeight") {
      return BoxFit.fitHeight;
    }
    return BoxFit.cover;
  }

  double getFontSize(String text, double width, double height) {
    int wordCount = text.split(' ').length;

    double minSize = height * 0.05;
    double maxSize = height * 0.1;

    double factor = (maxSize - minSize) / 50;
    double fontSize = maxSize - (factor * wordCount);

    return fontSize.clamp(minSize, maxSize);
  }

  Widget verseView(context) {
    var data = jsonDecode(json);
    previewController.verseText.value = data['verseText'];

    double fontSize = getFontSize(previewController.verseText.value, 300, 300);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
          onTap: () => onTap(),
          child: Container(
            padding: const EdgeInsets.all(2),
            margin: const EdgeInsets.all(20),
            height: 230,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.7)
                      : Colors.transparent,
                  width: 2),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 5,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(dataTypePath),
                    fit: getBoxFit(),
                  ),
                ),
                Center(
                  child: Stack(
                    children: [
                      Text(
                        previewController.verseText.value,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 4
                            ..color = Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        previewController.verseText.value,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  child: Stack(
                    children: [
                      Text(
                        "${data['book']} ${data['chapter']} ${data['verse']}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 4
                            ..color = Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "${data['book']} ${data['chapter']} ${data['verse']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  right: 5,
                  bottom: 5,
                )
              ],
            ),
          )),
    );
  }

  Widget songView(context) {
    var data = jsonDecode(json);
    previewController.verseText.value = data['paragraph'];

    double fontSize = getFontSize(previewController.verseText.value, 100, 260);
    return Stack(
      fit: StackFit.expand,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
              onTap: () => onTap(),
              child: Container(
                margin: const EdgeInsets.all(20),
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                      color: isSelected
                          ? Colors.blue.withOpacity(0.7)
                          : Colors.transparent,
                      width: isSelected ? 2 : 0),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 5,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(dataTypePath),
                        fit: getBoxFit(),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Center(
                        child: Stack(
                          children: [
                            Text(
                              previewController.verseText.value,
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 4
                                  ..color = Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              previewController.verseText.value,
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ],
    );
  }

  Widget previewView() {
    return Container(
      padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.all(20),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(dataTypePath),
              fit: getBoxFit(),
            ),
          ),
          Center(
            child: Stack(
              children: [
                Text(
                  "slide",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 4
                      ..color = Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  "slide",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget imageView(context) {
    var data = jsonDecode(json);

    previewController.path.value = data['path'];

    return Stack(
      fit: StackFit.expand,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
              onTap: () => onTap(),
              child: Container(
                margin: const EdgeInsets.all(20),
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                      color: isSelected
                          ? Colors.blue.withOpacity(0.7)
                          : Colors.transparent,
                      width: isSelected ? 2 : 0),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 5,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(previewController.path.value),
                        width: 200,
                        height: 100,
                        fit: getBoxFit(),
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ],
    );
  }

  Widget videoView(context) {
    var data = jsonDecode(json);
    previewController.path.value = data['firstFrame'];

    return Stack(
      fit: StackFit.expand,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
              onTap: () => onTap(),
              child: Container(
                padding: const EdgeInsets.all(2),
                margin: const EdgeInsets.all(20),
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                      color: isSelected
                          ? Colors.blue.withOpacity(0.7)
                          : Colors.transparent,
                      width: 2),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 5,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(previewController.path.value),
                        width: 200,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Icon(Icons.play_circle_filled,
                          color: Colors.white, size: 60),
                    ),
                  ],
                ),
              )),
        ),
      ],
    );
  }

  Widget getTypeView(context) {
    if (type == "verse") {
      return verseView(context);
    }
    if (type == "song") {
      return songView(context);
    }
    if (type == "image") {
      return imageView(context);
    }
    if (type == "video") {
      return videoView(context);
    }
    return previewView();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        getTypeView(context),
        Positioned(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "${index + 1}",
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          top: 10,
          left: 10,
        ),
        Positioned(
          child: Tooltip(
              message: "delete_slide".i18n(),
              child: InkWell(
                onTap: () async {
                  await presentController.deleteSlideFromPresentation(keyItem);
                },
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.delete,
                      size: 15,
                    ),
                  ),
                ),
              )),
          top: 10,
          right: 10,
        )
      ],
    );
  }
}
