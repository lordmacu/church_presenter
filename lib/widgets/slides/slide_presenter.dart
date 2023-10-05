import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ipuc/app/controllers/present_controller.dart';
import 'package:ipuc/app/controllers/preview_controller.dart';
import 'package:ipuc/app/controllers/slide_controller.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/views/gallery_view.dart';
import 'package:ipuc/app/views/videos_view.dart';
import 'package:ipuc/models/slide.dart';
import 'package:ipuc/widgets/slides/slide_grid.dart';
import 'package:ipuc/widgets/slides/slide_item.dart';
import 'package:ipuc/widgets/title_bar.dart';
import 'package:uuid/uuid.dart';
import 'package:animated_floating_buttons/animated_floating_buttons.dart';
import 'dart:io';

import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SlidePresenter extends StatelessWidget {
  final SliderController controller = Get.find();
  final PresentController controllerPresenter = Get.find();
  PreviewController previewController = Get.find();
  final GlobalKey<AnimatedFloatingActionButtonState> keyFloating =
      GlobalKey<AnimatedFloatingActionButtonState>();

  WoltModalSheetPage imageGalleryPage(
      BuildContext modalSheetContext, TextTheme textTheme) {
    return WoltModalSheetPage.withSingleChild(
      hasSabGradient: false,
      topBarTitle: Text('Galería', style: textTheme.titleSmall),
      isTopBarLayerAlwaysVisible: true,
      trailingNavBarWidget: IconButton(
        padding: const EdgeInsets.all(10),
        icon: const Icon(Icons.close),
        onPressed: Navigator.of(modalSheetContext).pop,
      ),
      child: Container(
        height: 500,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              // Añade este widget
              child: GalleryView(
                folderName: 'ipucImages',
                selectImage: (String image) async {
                  Slide currentSlide = controllerPresenter.selectSlide.value;
                  var json = jsonDecode(currentSlide.json);
                  if (currentSlide.type == "image") {
                    json["path"] = image;
                  }
                  controllerPresenter.selectSlide.value = Slide(
                      key: currentSlide.key,
                      type: currentSlide.type,
                      dataType: "image",
                      dataTypeMode: "cover",
                      dataTypePath: image,
                      json: jsonEncode(json));

                  for (int i = 0;
                      i <
                          controllerPresenter
                              .selectPresentation.value.slides.length;
                      i++) {
                    var element =
                        controllerPresenter.selectPresentation.value.slides[i];
                    if (currentSlide.key == element.key) {
                      controllerPresenter.selectPresentation.value.slides[i] =
                          controllerPresenter.selectSlide.value;
                    }
                  }

                  controllerPresenter.updateSlideInPresentation(
                      controllerPresenter.selectSlide.value);

                  await controllerPresenter.sendToViewer();
                  Navigator.of(modalSheetContext).pop();
                },
              ),
            ),
            Container(
              child: ElevatedButton(
                onPressed: () => Navigator.of(modalSheetContext).pop(),
                child: const SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: Center(child: Text('Cancelar')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  WoltModalSheetPage videoGalleryPage(
      BuildContext modalSheetContext, TextTheme textTheme) {
    return WoltModalSheetPage.withSingleChild(
      hasSabGradient: false,
      topBarTitle: Text('Videos', style: textTheme.titleSmall),
      isTopBarLayerAlwaysVisible: true,
      trailingNavBarWidget: IconButton(
        padding: const EdgeInsets.all(10),
        icon: const Icon(Icons.close),
        onPressed: Navigator.of(modalSheetContext).pop,
      ),
      child: Container(
        height: 500,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              // Añade este widget
              child: VideosView(
                folderName: 'ipucVideos',
                selectImage: (String image, String videoPath) async {
                  Slide currentSlide = controllerPresenter.selectSlide.value;
                  var jsonData = jsonDecode(currentSlide.json);

                  var jsonFinal = jsonEncode(jsonData);
                  controllerPresenter.selectSlide.value = Slide(
                      key: currentSlide.key,
                      type: currentSlide.type,
                      dataType: "video",
                      dataTypeMode: "cover",
                      dataTypePath: image,
                      json: jsonFinal);

                  for (int i = 0;
                      i <
                          controllerPresenter
                              .selectPresentation.value.slides.length;
                      i++) {
                    var element =
                        controllerPresenter.selectPresentation.value.slides[i];
                    if (currentSlide.key == element.key) {
                      controllerPresenter.selectPresentation.value.slides[i] =
                          controllerPresenter.selectSlide.value;
                    }
                  }
                  controllerPresenter.updateSlideInPresentation(
                      controllerPresenter.selectSlide.value);
                  await controllerPresenter.sendToViewerVideo(videoPath);
                  Navigator.of(modalSheetContext).pop();
                },
              ),
            ),
            Container(
              child: ElevatedButton(
                onPressed: () => Navigator.of(modalSheetContext).pop(),
                child: const SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: Center(child: Text('Cancelar')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget image() {
    return Container(
      child: FloatingActionButton(
        heroTag: "three",
        onPressed: () async {
          if (controllerPresenter.selectPresentation.value.key == "") {
            await controllerPresenter.addEmptyPresentation();
          }
          await controller.pickImage();

          var uuid = Uuid();
          final uniqueKey = uuid.v4();
          final payload =
              jsonEncode({"type": "image", "path": controller.image.value});

          controllerPresenter.setSlideToPresentation(Slide(
              key: uniqueKey,
              type: "image",
              dataType: "image",
              dataTypePath: controller.image.value,
              dataTypeMode: "cover",
              json: payload));

          controllerPresenter.selectSlide.value = Slide(
              key: uniqueKey,
              type: "image",
              dataType: "image",
              dataTypePath: controller.image.value,
              dataTypeMode: "cover",
              json: payload);

          keyFloating.currentState!.closeFABs();
        },
        tooltip: 'Agregar Imagen',
        child: Icon(Icons.image),
      ),
    );
  }

  Widget video() {
    return Container(
      child: FloatingActionButton(
        heroTag: "two",
        onPressed: () async {
          if (controllerPresenter.selectPresentation.value.key == "") {
            await controllerPresenter.addEmptyPresentation();
          }

          await controller.pickVideo();

          var uuid = Uuid();
          final uniqueKey = uuid.v4();
          final payload = jsonEncode({
            "type": "video",
            "path": controller.video.value,
            "firstFrame": controller.videoFirstFrame.value,
          });
          controllerPresenter.setSlideToPresentation(Slide(
              key: uniqueKey,
              type: "video",
              dataType: "video",
              dataTypePath: controller.video.value,
              dataTypeMode: "cover",
              json: payload));

          controllerPresenter.selectSlide.value = Slide(
              key: uniqueKey,
              type: "video",
              dataType: "video",
              dataTypePath: controller.video.value,
              dataTypeMode: "cover",
              json: payload);
          keyFloating.currentState!.closeFABs();
        },
        tooltip: 'Agregar Video',
        child: Icon(Icons.video_call),
      ),
    );
  }

  Future<String?> getRandomImage() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String docPath = appDocDir.path;
    final directory = Directory('$docPath/ipucImages');
    final List<FileSystemEntity> files = directory.listSync();

    // Filtrar solo archivos de imagen
    final imageFiles = files.where((file) {
      return file is File &&
          (file.path.endsWith('.jpg') || file.path.endsWith('.png'));
    }).toList();

    if (imageFiles.isEmpty) {
      return null; // Devuelve null si no hay imágenes
    }

    // Obtener un archivo de imagen aleatorio
    final random = Random();
    final randomIndex = random.nextInt(imageFiles.length);
    File imageFile = imageFiles[randomIndex] as File;
    return imageFile.path;
  }

  Widget text() {
    return Container(
      child: FloatingActionButton(
        onPressed: () async {
          if (controllerPresenter.selectPresentation.value.key == "") {
            await controllerPresenter.addEmptyPresentation();
          }
          var uuid = Uuid();
          final uniqueKey = uuid.v4();
          final payload = jsonEncode({
            "type": "image",
          });

          String? imageRandom = await getRandomImage();
          controllerPresenter.setSlideToPresentation(Slide(
              key: uniqueKey,
              type: "image",
              dataType: "image",
              dataTypePath: imageRandom!,
              dataTypeMode: "cover",
              json: payload));

          keyFloating.currentState!.closeFABs();
        },
        tooltip: 'Agregar Texto',
        heroTag: "one",
        child: Icon(Icons.text_format),
      ),
    );
  }

  Widget buildOption({
    required String tooltip,
    required IconData icon,
    required String selectedOption,
  }) {
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: controller.selectedOptionImage.value == selectedOption
                  ? Colors.white.withOpacity(0.3)
                  : null,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          onTap: () async {
            controller.selectedOptionImage.value = selectedOption;

            Slide currentSlide = controllerPresenter.selectSlide.value;
            controllerPresenter.selectSlide.value = Slide(
                key: currentSlide.key,
                type: currentSlide.type,
                dataType: currentSlide.dataType,
                dataTypeMode: selectedOption,
                dataTypePath: currentSlide.dataTypePath,
                json: currentSlide.json);

            for (int i = 0;
                i < controllerPresenter.selectPresentation.value.slides.length;
                i++) {
              var element =
                  controllerPresenter.selectPresentation.value.slides[i];
              if (currentSlide.key == element.key) {
                controllerPresenter.selectPresentation.value.slides[i] =
                    controllerPresenter.selectSlide.value;
              }
            }

            await controllerPresenter.sendToViewer();
          },
        ),
      ),
    );
  }

  Widget buildOptioVideo({
    required String tooltip,
    required IconData icon,
    required String selectedOption,
  }) {
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: controller.selectedOptionVideo.value == selectedOption
                  ? Colors.white.withOpacity(0.3)
                  : null,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          onTap: () {
            controller.selectedOptionVideo.value = selectedOption;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageIndexNotifier = ValueNotifier(0);

    return Scaffold(
      floatingActionButton: AnimatedFloatingActionButton(
        //Fab list
        fabButtons: <Widget>[image(), video(), text()],
        key: keyFloating,
        colorStartAnimation: Colors.blue,
        colorEndAnimation: Colors.red,
        animatedIconData: AnimatedIcons.menu_close,
        //To principal button
      ),
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          TitleBar(title: "Diapositivas"),
          Obx(
            () => Container(
                padding: EdgeInsets.only(top: 0, bottom: 10),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      child: Container(
                        width: 55,
                        padding: EdgeInsets.only(left: 5, right: 5),
                        margin: EdgeInsets.only(left: 20, right: 20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            Tooltip(
                              message: "Limpiar",
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  child: Container(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.only(
                                        right: 5, top: 5, bottom: 5),
                                    child: const Icon(
                                      Icons.clear_all,
                                      size: 40,
                                    ),
                                  ),
                                  onTap: () async {
                                    // Mostrar un cuadro de diálogo de alerta para confirmar
                                    final bool? result = await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Confirmación"),
                                          content: Text(
                                              "¿Seguro que quieres limpiar los slides?"),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text("Cancelar"),
                                              onPressed: () {
                                                Navigator.of(context).pop(
                                                    false); // Devuelve 'false' cuando el usuario pulsa 'Cancelar'
                                              },
                                            ),
                                            TextButton(
                                              child: Text("Aceptar"),
                                              onPressed: () {
                                                Navigator.of(context).pop(
                                                    true); // Devuelve 'true' cuando el usuario pulsa 'Aceptar'
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    // Si el usuario confirmó la acción
                                    if (result == true) {
                                      controllerPresenter
                                          .deleteAllSlideToPresentation();
                                      controllerPresenter.resetSlide();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            Tooltip(
                                message: "Enviar presentación vacia",
                                child: Container(
                                  child: InkWell(
                                    onTap: () async {
                                      await controllerPresenter
                                          .sendToPresentation(null);
                                    },
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.blue,
                                            Colors.blueAccent
                                          ],
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
                                )),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          controllerPresenter.selectSlide.value.type != "image"
                              ? Container(
                                  padding: EdgeInsets.only(left: 5, right: 5),
                                  margin: EdgeInsets.only(left: 20, right: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Tooltip(
                                        message: "Seleccionar video",
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            child: Container(
                                              color: Colors.transparent,
                                              padding: EdgeInsets.only(
                                                  right: 5, top: 5, bottom: 5),
                                              child: const Icon(
                                                Icons.video_call,
                                                size: 40,
                                              ),
                                            ),
                                            onTap: () async {
                                              final pageIndexNotifier =
                                                  ValueNotifier(1);

                                              WoltModalSheet.show<void>(
                                                pageIndexNotifier:
                                                    pageIndexNotifier,
                                                context: context,
                                                pageListBuilder:
                                                    (modalSheetContext) {
                                                  final textTheme =
                                                      Theme.of(context)
                                                          .textTheme;
                                                  return [
                                                    imageGalleryPage(
                                                        modalSheetContext,
                                                        textTheme),
                                                    videoGalleryPage(
                                                        modalSheetContext,
                                                        textTheme),
                                                  ];
                                                },
                                                modalTypeBuilder: (context) {
                                                  return WoltModalType.dialog;
                                                },
                                                onModalDismissedWithBarrierTap:
                                                    () {},
                                                maxDialogWidth: 1000,
                                                minDialogWidth: 1000,
                                                minPageHeight: 0.0,
                                                maxPageHeight: 0.9,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Obx(
                                        () => controllerPresenter.selectSlide
                                                    .value.dataType ==
                                                "video"
                                            ? Container(
                                                padding:
                                                    EdgeInsets.only(left: 5),
                                                child: Row(
                                                  children: [
                                                    buildOptioVideo(
                                                      tooltip: "Play",
                                                      icon: Icons.play_arrow,
                                                      selectedOption: "fill",
                                                    ),
                                                    buildOptioVideo(
                                                      tooltip: "Pausar",
                                                      icon: Icons.pause,
                                                      selectedOption: "contain",
                                                    ),
                                                    buildOptioVideo(
                                                      tooltip: "Reiniciar",
                                                      icon: Icons.restart_alt,
                                                      selectedOption:
                                                          "fitWidth",
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          controllerPresenter.selectSlide.value.type != "video"
                              ? Container(
                                  margin: EdgeInsets.only(left: 20, right: 20),
                                  padding: EdgeInsets.only(left: 5, right: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Tooltip(
                                        message: "Seleccionar Imagen",
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            child: Container(
                                              color: Colors.transparent,
                                              padding: EdgeInsets.only(
                                                  right: 5, top: 5, bottom: 5),
                                              child: Icon(
                                                Icons.add_a_photo,
                                                size: 40,
                                              ),
                                            ),
                                            onTap: () async {
                                              final pageIndexNotifier =
                                                  ValueNotifier(0);

                                              WoltModalSheet.show<void>(
                                                pageIndexNotifier:
                                                    pageIndexNotifier,
                                                context: context,
                                                pageListBuilder:
                                                    (modalSheetContext) {
                                                  final textTheme =
                                                      Theme.of(context)
                                                          .textTheme;
                                                  return [
                                                    imageGalleryPage(
                                                        modalSheetContext,
                                                        textTheme),
                                                    videoGalleryPage(
                                                        modalSheetContext,
                                                        textTheme),
                                                  ];
                                                },
                                                modalTypeBuilder: (context) {
                                                  return WoltModalType.dialog;
                                                },
                                                onModalDismissedWithBarrierTap:
                                                    () {},
                                                maxDialogWidth: 1000,
                                                minDialogWidth: 1000,
                                                minPageHeight: 0.0,
                                                maxPageHeight: 0.9,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Obx(
                                        () => controllerPresenter.selectSlide
                                                    .value.dataType ==
                                                "image"
                                            ? Container(
                                                padding:
                                                    EdgeInsets.only(left: 5),
                                                child: Row(
                                                  children: [
                                                    buildOption(
                                                      tooltip: "Llenar",
                                                      icon: Icons.aspect_ratio,
                                                      selectedOption: "fill",
                                                    ),
                                                    buildOption(
                                                      tooltip: "Contener",
                                                      icon: Icons.zoom_out_map,
                                                      selectedOption: "contain",
                                                    ),
                                                    buildOption(
                                                      tooltip: "Cover",
                                                      icon: Icons.crop,
                                                      selectedOption: "cover",
                                                    ),
                                                    buildOption(
                                                      tooltip: "Ajustar ancho",
                                                      icon: Icons
                                                          .photo_size_select_large,
                                                      selectedOption:
                                                          "fitWidth",
                                                    ),
                                                    buildOption(
                                                      tooltip: "Ajustar altura",
                                                      icon: Icons
                                                          .photo_size_select_small,
                                                      selectedOption:
                                                          "fitHeight",
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                      ),
                                    ],
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    )
                  ],
                )),
          ),
          Expanded(
            child: SlideGrid(),
          )
        ],
      ),
    );
  }
}

/*  floatingActionButton: FloatingActionButton(
        onPressed: () {
          var uuid = Uuid();
          final uniqueKey = uuid.v4();
          final payload = jsonEncode({
            "type": "image",
          });
          controllerPresenter.setSlideToPresentation(
              Slide(key: uniqueKey, type: "song", dataType: "", json: payload));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),*/
