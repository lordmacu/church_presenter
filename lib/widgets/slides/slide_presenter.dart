import 'dart:convert';
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
import 'package:ipuc/widgets/title_bar.dart';
import 'package:localization/localization.dart';
import 'package:uuid/uuid.dart';
import 'package:animated_floating_buttons/animated_floating_buttons.dart';
import 'dart:io';

import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import 'package:path_provider/path_provider.dart';

class SlidePresenter extends StatelessWidget {
  SlidePresenter({Key? key}) : super(key: key);
  final SliderController controller = Get.find();
  final PresentController controllerPresenter = Get.find();
  final PreviewController previewController = Get.find();
  final GlobalKey<AnimatedFloatingActionButtonState> keyFloating =
      GlobalKey<AnimatedFloatingActionButtonState>();

  WoltModalSheetPage imageGalleryPage(
      BuildContext modalSheetContext, TextTheme textTheme) {
    return WoltModalSheetPage.withSingleChild(
      hasSabGradient: false,
      topBarTitle: Text('gallery'.i18n(), style: textTheme.titleSmall),
      isTopBarLayerAlwaysVisible: true,
      trailingNavBarWidget: IconButton(
        padding: const EdgeInsets.all(10),
        icon: const Icon(Icons.close),
        onPressed: Navigator.of(modalSheetContext).pop,
      ),
      child: SizedBox(
        height: 500,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: GalleryView(
                folderName: 'ipucImages',
                selectImage: (String image) async {
                  Slide currentSlide = controllerPresenter.selectedSlide.value;
                  var json = jsonDecode(currentSlide.json);
                  if (currentSlide.type == "image") {
                    json["path"] = image;
                  }
                  controllerPresenter.selectedSlide.value = Slide(
                      key: currentSlide.key,
                      type: currentSlide.type,
                      dataType: "image",
                      dataTypeMode: "cover",
                      dataTypePath: image,
                      json: jsonEncode(json));

                  for (int i = 0;
                      i <
                          controllerPresenter
                              .selectedPresentation.value.slides.length;
                      i++) {
                    var element = controllerPresenter
                        .selectedPresentation.value.slides[i];
                    if (currentSlide.key == element.key) {
                      controllerPresenter.selectedPresentation.value.slides[i] =
                          controllerPresenter.selectedSlide.value;
                    }
                  }

                  controllerPresenter.updateSlideInPresentation(
                      controllerPresenter.selectedSlide.value);

                  await controllerPresenter.sendToViewer();
                  Navigator.of(modalSheetContext).pop();
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(modalSheetContext).pop(),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: Center(child: Text('cancel'.i18n())),
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
      topBarTitle: Text('videos'.i18n(), style: textTheme.titleSmall),
      isTopBarLayerAlwaysVisible: true,
      trailingNavBarWidget: IconButton(
        padding: const EdgeInsets.all(10),
        icon: const Icon(Icons.close),
        onPressed: Navigator.of(modalSheetContext).pop,
      ),
      child: SizedBox(
        height: 500,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: VideosView(
                folderName: 'ipucVideos',
                selectImage: (String image, String videoPath) async {
                  Slide currentSlide = controllerPresenter.selectedSlide.value;
                  var jsonData = jsonDecode(currentSlide.json);
                  jsonData["videoPath"] = videoPath;

                  var jsonFinal = jsonEncode(jsonData);
                  controllerPresenter.selectedSlide.value = Slide(
                      key: currentSlide.key,
                      type: currentSlide.type,
                      dataType: "video",
                      dataTypeMode: "cover",
                      dataTypePath: image,
                      json: jsonFinal);

                  for (int i = 0;
                      i <
                          controllerPresenter
                              .selectedPresentation.value.slides.length;
                      i++) {
                    var element = controllerPresenter
                        .selectedPresentation.value.slides[i];
                    if (currentSlide.key == element.key) {
                      controllerPresenter.selectedPresentation.value.slides[i] =
                          controllerPresenter.selectedSlide.value;
                    }
                  }
                  controllerPresenter.updateSlideInPresentation(
                      controllerPresenter.selectedSlide.value);
                  await controllerPresenter.sendToViewerVideo(videoPath);
                  Navigator.of(modalSheetContext).pop();
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(modalSheetContext).pop(),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: Center(child: Text('cancel'.i18n())),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget image() {
    return FloatingActionButton(
      heroTag: "three",
      onPressed: () async {
        if (controllerPresenter.selectedPresentation.value.key == "") {
          await controllerPresenter.addEmptyPresentation();
        }
        await controller.pickImage();

        var uuid = const Uuid();
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

        controllerPresenter.selectedSlide.value = Slide(
            key: uniqueKey,
            type: "image",
            dataType: "image",
            dataTypePath: controller.image.value,
            dataTypeMode: "cover",
            json: payload);

        keyFloating.currentState!.closeFABs();
      },
      tooltip: 'add_image'.i18n(),
      child: const Icon(Icons.image),
    );
  }

  Widget video() {
    return FloatingActionButton(
      heroTag: "two",
      onPressed: () async {
        if (controllerPresenter.selectedPresentation.value.key == "") {
          await controllerPresenter.addEmptyPresentation();
        }

        await controller.pickVideo();

        var uuid = const Uuid();
        final uniqueKey = uuid.v4();
        final payload = jsonEncode({
          "type": "video",
          "path": controller.video.value,
          "firstFrame": controller.videoFirstFrame.value,
          "videoPath": controller.video.value
        });

        controllerPresenter.setSlideToPresentation(Slide(
            key: uniqueKey,
            type: "video",
            dataType: "video",
            dataTypePath: controller.video.value,
            dataTypeMode: "play",
            json: payload));

        controllerPresenter.selectedSlide.value = Slide(
            key: uniqueKey,
            type: "video",
            dataType: "video",
            dataTypePath: controller.video.value,
            dataTypeMode: "cover",
            json: payload);
        keyFloating.currentState!.closeFABs();
      },
      tooltip: 'add_video'.i18n(),
      child: const Icon(Icons.video_call),
    );
  }

  Future<String?> getRandomImage() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String docPath = appDocDir.path;
    final directory = Directory('$docPath/ipucImages');
    final List<FileSystemEntity> files = directory.listSync();

    final imageFiles = files.where((file) {
      return file is File &&
          (file.path.endsWith('.jpg') || file.path.endsWith('.png'));
    }).toList();

    if (imageFiles.isEmpty) {
      return null;
    }

    final random = Random();
    final randomIndex = random.nextInt(imageFiles.length);
    File imageFile = imageFiles[randomIndex] as File;
    return imageFile.path;
  }

  Widget text() {
    return FloatingActionButton(
      onPressed: () async {
        if (controllerPresenter.selectedPresentation.value.key == "") {
          await controllerPresenter.addEmptyPresentation();
        }

        keyFloating.currentState!.closeFABs();
      },
      tooltip: 'add_text'.i18n(),
      heroTag: "one",
      child: const Icon(Icons.text_format),
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
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          onTap: () async {
            controller.selectedOptionImage.value = selectedOption;

            Slide currentSlide = controllerPresenter.selectedSlide.value;
            controllerPresenter.selectedSlide.value = Slide(
                key: currentSlide.key,
                type: currentSlide.type,
                dataType: currentSlide.dataType,
                dataTypeMode: selectedOption,
                dataTypePath: currentSlide.dataTypePath,
                json: currentSlide.json);

            for (int i = 0;
                i <
                    controllerPresenter
                        .selectedPresentation.value.slides.length;
                i++) {
              var element =
                  controllerPresenter.selectedPresentation.value.slides[i];
              if (currentSlide.key == element.key) {
                controllerPresenter.selectedPresentation.value.slides[i] =
                    controllerPresenter.selectedSlide.value;
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
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          onTap: () async {
            controller.selectedOptionVideo.value = selectedOption;

            Slide currentSlide = controllerPresenter.selectedSlide.value;
            controllerPresenter.selectedSlide.value = Slide(
                key: currentSlide.key,
                type: currentSlide.type,
                dataType: currentSlide.dataType,
                dataTypeMode: selectedOption,
                dataTypePath: currentSlide.dataTypePath,
                json: currentSlide.json);

            for (int i = 0;
                i <
                    controllerPresenter
                        .selectedPresentation.value.slides.length;
                i++) {
              var element =
                  controllerPresenter.selectedPresentation.value.slides[i];
              if (currentSlide.key == element.key) {
                controllerPresenter.selectedPresentation.value.slides[i] =
                    controllerPresenter.selectedSlide.value;
              }
            }

            await controllerPresenter.sendToViewer();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AnimatedFloatingActionButton(
        fabButtons: <Widget>[image(), video(), text()],
        key: keyFloating,
        animatedIconData: AnimatedIcons.menu_close,
        tooltip: "add_resource".i18n(),
      ),
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          TitleBar(title: "slides".i18n()),
          Obx(
            () => Container(
                padding: const EdgeInsets.only(top: 0, bottom: 10),
                height: 60,
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      child: Container(
                        width: 55,
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: controllerPresenter
                                .selectedPresentation.value.slides.isNotEmpty
                            ? Row(
                                children: [
                                  Tooltip(
                                    message: "delete_all_slides".i18n(),
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        child: Container(
                                          color: Colors.transparent,
                                          padding: const EdgeInsets.only(
                                              right: 5, top: 5, bottom: 5),
                                          child: const Icon(
                                            Icons.clear_all,
                                            size: 40,
                                          ),
                                        ),
                                        onTap: () async {
                                          final bool? result =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title:
                                                    Text("confirmation".i18n()),
                                                content: Text(
                                                    "confirm_delete_slide"
                                                        .i18n()),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child:
                                                        Text("cancel".i18n()),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(false);
                                                    },
                                                  ),
                                                  TextButton(
                                                    child:
                                                        Text("accept".i18n()),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (result == true) {
                                            controllerPresenter
                                                .deleteAllSlidesFromPresentation();
                                            controllerPresenter
                                                .resetSelectedSlide();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            Tooltip(
                              message: "send_empty_presentation".i18n(),
                              child: InkWell(
                                onTap: () async {
                                  await controllerPresenter
                                      .sendDataToPresentation(null);
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Colors.blue, Colors.blueAccent],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: const [
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
                            ),
                          ],
                        ),
                      ),
                    ),
                    controllerPresenter
                            .selectedPresentation.value.slides.isNotEmpty
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              controllerPresenter.selectedSlide.value.type !=
                                      "image"
                                  ? Container(
                                      padding: const EdgeInsets.only(
                                          left: 5, right: 5),
                                      margin: const EdgeInsets.only(
                                          left: 20, right: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Tooltip(
                                            message: "select_video".i18n(),
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                child: Container(
                                                  color: Colors.transparent,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 5,
                                                          top: 5,
                                                          bottom: 5),
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
                                                    modalTypeBuilder:
                                                        (context) {
                                                      return WoltModalType
                                                          .dialog;
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
                                            () => controllerPresenter
                                                        .selectedSlide
                                                        .value
                                                        .dataType ==
                                                    "video"
                                                ? Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    child: Row(
                                                      children: [
                                                        buildOptioVideo(
                                                          tooltip:
                                                              "play".i18n(),
                                                          icon:
                                                              Icons.play_arrow,
                                                          selectedOption:
                                                              "play",
                                                        ),
                                                        buildOptioVideo(
                                                          tooltip:
                                                              "pause".i18n(),
                                                          icon: Icons.pause,
                                                          selectedOption:
                                                              "pause",
                                                        ),
                                                        buildOptioVideo(
                                                          tooltip:
                                                              "reset".i18n(),
                                                          icon:
                                                              Icons.restart_alt,
                                                          selectedOption:
                                                              "reset",
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
                              controllerPresenter.selectedSlide.value.type !=
                                      "video"
                                  ? Container(
                                      margin: const EdgeInsets.only(
                                          left: 20, right: 20),
                                      padding: const EdgeInsets.only(
                                          left: 5, right: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Tooltip(
                                            message: "select_image".i18n(),
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                child: Container(
                                                  color: Colors.transparent,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 5,
                                                          top: 10,
                                                          bottom: 10),
                                                  child: const Icon(
                                                    Icons.add_a_photo,
                                                    size: 30,
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
                                                    modalTypeBuilder:
                                                        (context) {
                                                      return WoltModalType
                                                          .dialog;
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
                                            () => controllerPresenter
                                                        .selectedSlide
                                                        .value
                                                        .dataType ==
                                                    "image"
                                                ? Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    child: Row(
                                                      children: [
                                                        buildOption(
                                                          tooltip:
                                                              "fill".i18n(),
                                                          icon: Icons
                                                              .aspect_ratio,
                                                          selectedOption:
                                                              "fill",
                                                        ),
                                                        buildOption(
                                                          tooltip:
                                                              "contain".i18n(),
                                                          icon: Icons
                                                              .zoom_out_map,
                                                          selectedOption:
                                                              "contain",
                                                        ),
                                                        buildOption(
                                                          tooltip:
                                                              "cover".i18n(),
                                                          icon: Icons.crop,
                                                          selectedOption:
                                                              "cover",
                                                        ),
                                                        buildOption(
                                                          tooltip:
                                                              "fitwidth".i18n(),
                                                          icon: Icons
                                                              .photo_size_select_large,
                                                          selectedOption:
                                                              "fitWidth",
                                                        ),
                                                        buildOption(
                                                          tooltip: "fitheight"
                                                              .i18n(),
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
                          )
                        : Container(),
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
