import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/present_controller.dart';
import 'package:ipuc/app/controllers/preview_controller.dart';

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

  void _showPopupMenu(Offset offset, BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, 0.0, 0.0),
      items: <PopupMenuEntry>[
        const PopupMenuItem(
          value: 'Option 1',
          child: Text('Option 1'),
        ),
        const PopupMenuItem(
          value: 'Option 2',
          child: Text('Option 2'),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value != null) {}
    });
  }

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

    double minSize = height * 0.05; // 5% de la altura de la pantalla
    double maxSize = height * 0.1; // 10% de la altura de la pantalla

    double factor = (maxSize - minSize) /
        50; // 50 es un conteo de palabras arbitrariamente grande
    double fontSize = maxSize - (factor * wordCount);

    return fontSize.clamp(minSize, maxSize);
  }

  Widget verseView(context) {
    var data = jsonDecode(json);
    previewController.verseText.value = data['verseText'];

    double fontSize = getFontSize(previewController.verseText.value, 300, 300);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Listener(
        onPointerDown: (PointerDownEvent event) {
          if (event.kind == PointerDeviceKind.mouse &&
              event.buttons == kSecondaryMouseButton) {
            _showPopupMenu(event.position, context);
          }
        },
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
                        // Black border
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
                        // White text
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
                        // Black border
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
                        // White text
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
      ),
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
          child: Listener(
            onPointerDown: (PointerDownEvent event) {
              if (event.kind == PointerDeviceKind.mouse &&
                  event.buttons == kSecondaryMouseButton) {
                _showPopupMenu(event.position, context);
              }
            },
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
                          File(dataTypePath),
                          fit: getBoxFit(),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Center(
                          child: Stack(
                            children: [
                              // Black border
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
                              // White text
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
        ),
        Positioned(
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Stack(
              children: [
                // Black border
                Text(
                  "${data['title']}",
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
                // White text
                Text(
                  "${data['title']}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          left: 20,
          bottom: 0,
        )
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
                // Black border
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
                // White text
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
          child: Listener(
            onPointerDown: (PointerDownEvent event) {
              if (event.kind == PointerDeviceKind.mouse &&
                  event.buttons == kSecondaryMouseButton) {
                _showPopupMenu(event.position, context);
              }
            },
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
                          fit: getBoxFit(),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
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
          child: Listener(
            onPointerDown: (PointerDownEvent event) {
              if (event.kind == PointerDeviceKind.mouse &&
                  event.buttons == kSecondaryMouseButton) {
                _showPopupMenu(event.position, context);
              }
            },
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
            padding: const EdgeInsets.all(
                8.0), // Agrega un poco de espacio alrededor del texto
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.8),
              shape: BoxShape.circle, // Hace que el contenedor sea circular
            ),
            child: Center(
              child: Text(
                "${index + 1}",
                style: const TextStyle(
                  color: Colors.white, // Configura el color del texto a blanco
                ),
              ),
            ),
          ),
          top: 10,
          left: 10,
        ),
        Positioned(
          child: Tooltip(
              message: "Borrar Slide",
              child: InkWell(
                onTap: () async {
                  await presentController.deleteSlideToPresentation(keyItem);
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
                      size: 20,
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
