import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:ipuc/app/controllers/slide_controller.dart';
import 'package:ipuc/models/presentation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ipuc/models/slide.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:uuid/uuid.dart';

class PresentController extends GetxController {
  /// Selected item for some purpose.
  var selectedItem = RxString("");

  /// Height of the selected item.
  var heightItem = RxDouble(0.0);

  /// Topic of the presentation.
  var topic = RxString("");

  /// Unique identifier for various entities.
  var key = RxString("");

  /// Preacher in the presentation.
  var preacher = RxString("");

  /// Image URL or path.
  var image = RxString("");

  /// Name of the presentation or slide.
  var name = RxString("");

  /// Indicates whether the data is being saved.
  var isSaving = RxBool(false);

  /// Date of the presentation.
  var date = Rx<DateTime>(DateTime.now());

  /// Identifier for the presentation or slide.
  var id = RxInt(0);

  /// Indicates whether the panel is open.
  var isPanelOpen = false.obs;

  /// Currently selected presentation.
  var selectedPresentation = Presentation(
    key: "",
    image: "",
    name: "",
    date: DateTime.now(),
    preacher: "",
    topic: "",
    slides: RxList<Slide>([]),
  ).obs;

  /// Currently selected slide.
  var selectedSlide = Slide(
    key: "",
    type: "",
    dataType: "",
    json: "",
    dataTypePath: "",
    dataTypeMode: "cover",
  ).obs;

  /// List of all presentations.
  RxList<Presentation> presentations = RxList<Presentation>();

  /// Controller for managing slides.
  final SliderController slideController = Get.find();

  /// Responsible for picking an image from the gallery and storing it.
  Future<void> pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = path.basename(pickedFile.path);
        final File savedImage =
            await File(pickedFile.path).copy('${directory.path}/$fileName');

        image.value = savedImage.path;
      }
    } catch (e) {
      // Handle exceptions
      print("Error picking image: $e");
    }
  }

  /// Resets the currently selected slide to its default state.
  void resetSelectedSlide() {
    selectedSlide.value = Slide(
      key: "",
      type: "",
      dataType: "",
      json: "",
      dataTypePath: "",
      dataTypeMode: "cover",
    );
  }

  /// Creates a new window and sets its properties.
  Future<void> createNewWindow() async {
    try {
      final window = await DesktopMultiWindow.createWindow(jsonEncode({
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
    } catch (e) {
      // Handle exceptions
      print("Error creating new window: $e");
    }
  }

  /// Sends data to the presentation window.
  ///
  /// @param {dynamic} payload - The data to be sent to the presentation.
  Future<void> sendDataToPresentation(dynamic payload) async {
    List<int> subWindowIds;
    try {
      subWindowIds = await getAllSubWindowIds();

      if (payload != null) {
        if (selectedSlide.value.key.isEmpty) {
          await sendRandomDataType();
        } else {
          await sendCurrentSlideDataToViewer(subWindowIds);
        }

        await sendDataToViewer(payload, subWindowIds);
      }
    } catch (e) {
      await createNewWindow();
      subWindowIds = await getAllSubWindowIds();

      if (selectedSlide.value.key.isEmpty) {
        await sendRandomDataType();
      } else {
        await sendCurrentSlideDataToViewer(subWindowIds);
      }

      await sendDataToViewer(payload, subWindowIds);
    }
  }

  /// Sends the current slide's data type information to the viewer.
  ///
  /// @param {List<String>} subWindowIds - The list of sub-window IDs.
  Future<void> sendCurrentSlideDataToViewer(List<int> subWindowIds) async {
    String payloadDataType;
    Slide slide = selectedSlide.value;

    payloadDataType = jsonEncode({
      "dataType": slide.dataType,
      "dataTypePath": slide.dataTypePath,
      "dataTypeMode": slide.dataTypeMode,
    });

    await DesktopMultiWindow.invokeMethod(
        subWindowIds[0], "send_data_type", payloadDataType);
  }

  /// Sends data to the viewer.
  ///
  /// @param {dynamic} payload - The payload to be sent to the viewer.
  /// @param {List<String>} subWindowIds - The list of sub-window IDs.
  Future<void> sendDataToViewer(dynamic payload, List<int> subWindowIds) async {
    await DesktopMultiWindow.invokeMethod(
        subWindowIds[0], "send_viewer", payload);
  }

  /// Sends a random data type to the viewer.
  Future<void> sendRandomDataType() async {
    List<int> subWindowIds = await getAllSubWindowIds();
    String? randomImage = await slideController.getRandomImage();

    final payloadDataType = jsonEncode({
      "dataType": "image",
      "dataTypePath": "$randomImage",
      "dataTypeMode": "cover"
    });

    await DesktopMultiWindow.invokeMethod(
        subWindowIds[0], "send_data_type", payloadDataType);
  }

  /// Gets the list of all sub-window IDs.
  ///
  /// @returns {Future<List<int>>} - The list of all sub-window IDs.
  Future<List<int>> getAllSubWindowIds() async {
    return await DesktopMultiWindow.getAllSubWindowIds();
  }

  /// Sends the current slide data to the viewer.
  Future<void> sendToViewer() async {
    try {
      final List<int> subWindowIds =
          await DesktopMultiWindow.getAllSubWindowIds();
      // TODO: Unclear why this line is here as its return value is not being used.
      jsonEncode(selectedSlide.value.json);

      final String payloadDataType = jsonEncode({
        "dataType": selectedSlide.value.dataType,
        "dataTypePath": selectedSlide.value.dataTypePath,
        "dataTypeMode": selectedSlide.value.dataTypeMode,
      });
      print("aquii las subwindows ${subWindowIds.length}");

      await DesktopMultiWindow.invokeMethod(
          subWindowIds[0], "send_data_type", payloadDataType);
    } catch (e) {
      // TODO: Add logging or some sort of error handling here
    }
  }

  /// Sends video data to the viewer.
  ///
  /// @param {String} video - The path to the video file.
  Future<void> sendToViewerVideo(String video) async {
    try {
      final List<int> subWindowIds =
          await DesktopMultiWindow.getAllSubWindowIds();
      Map<String, dynamic> jsonData = jsonDecode(selectedSlide.value.json);

      final String payloadDataType = jsonEncode({
        "dataType": selectedSlide.value.dataType,
        "dataTypePath": selectedSlide.value.dataTypePath,
        "dataTypeMode": "new",
        "dataVideoPath": jsonData["videoPath"],
      });

      print("aquii las subwindows ${subWindowIds.length}");
      await DesktopMultiWindow.invokeMethod(
          subWindowIds[0], "send_data_type", payloadDataType);
    } catch (e) {
      // TODO: Add logging or some sort of error handling here
    }
  }

  /// Resets values for a new presentation.
  ///
  /// @param {double} height - The height for the item.
  Future<void> resetValues(double height) async {
    heightItem.value = height;
    topic.value = "";
    preacher.value = "";
    image.value = "";
    id.value = 0;
  }

  /// Selects an item based on the key.
  ///
  /// @param {String} key - The key of the item to select.
  Future<void> selectItem(String key) async {
    selectedItem.value = key;
    Box<Presentation>? box;

    try {
      box = await Hive.openBox<Presentation>('presentations');
      List<Presentation> presentationsList = box.values.toList();
      int index = presentationsList
          .indexWhere((presentation) => presentation.key == key);

      if (index != -1) {
        selectedPresentation.value = presentationsList[index];
      }
    } catch (e) {
      // TODO: Add logging or some sort of error handling here
    } finally {
      box?.close();
    }
  }

  /// Updates or sets the current slide into the selected presentation.
  ///
  /// @param {Slide} newSlide - The new slide to set or update.
  Future<void> setSlideToPresentation(Slide newSlide) async {
    Box<Presentation>? box;

    try {
      box = await Hive.openBox<Presentation>('presentations');

      if (selectedPresentation.value.key != null) {
        int? key = findIndexByValue(box, selectedPresentation.value.key);

        if (key != null) {
          selectedPresentation.value.slides.add(newSlide);
          await box.put(key, selectedPresentation.value);
          update(); // TODO: Consider adding a more descriptive method name.
        }
      }
    } catch (e) {
      // TODO: Add logging or some sort of error handling here.
    } finally {
      box?.close();
    }
  }

  /// Updates a slide in the currently selected presentation.
  ///
  /// @param {Slide} newSlide - The new slide data.
  Future<void> updateSlideInPresentation(Slide newSlide) async {
    Box<Presentation>? presentationBox;

    try {
      presentationBox = await Hive.openBox<Presentation>('presentations');

      if (selectedPresentation.value.key != null) {
        int? hiveKey =
            findIndexByValue(presentationBox, selectedPresentation.value.key);

        if (hiveKey != null) {
          updateSlideInSelectedPresentation(newSlide);
          await presentationBox.put(hiveKey, selectedPresentation.value);
          update(); // TODO: Consider adding a more descriptive method name.
        }
      }
    } catch (e) {
      // TODO: Add logging or some sort of error handling here.
    } finally {
      await presentationBox?.close();
    }
  }

  /// Updates a slide in the selected presentation's slides list.
  ///
  /// @param {Slide} newSlide - The new slide data.
  void updateSlideInSelectedPresentation(Slide newSlide) {
    for (var i = 0; i < selectedPresentation.value.slides.length; i++) {
      if (selectedPresentation.value.slides[i].key == newSlide.key) {
        selectedPresentation.value.slides[i] = newSlide;
        break;
      }
    }
  }

  /// Deletes a slide from the selected presentation.
  ///
  /// @param {String} slideKey - The key of the slide to delete.
  Future<void> deleteSlideFromPresentation(String slideKey) async {
    Box<Presentation>? box;

    try {
      box = await Hive.openBox<Presentation>('presentations');

      if (selectedPresentation.value.key != null) {
        int? key = findIndexByValue(box, selectedPresentation.value.key);

        if (key != null) {
          List<Slide> filteredSlidesList = selectedPresentation.value.slides
              .where((slide) => slide.key != slideKey)
              .toList();

          RxList<Slide> filteredSlides = RxList<Slide>.from(filteredSlidesList);

          Presentation currentPresentation = selectedPresentation.value;

          selectedPresentation.value = Presentation(
              key: currentPresentation.key,
              image: currentPresentation.image,
              name: currentPresentation.name,
              date: currentPresentation.date,
              preacher: currentPresentation.preacher,
              topic: currentPresentation.topic,
              slides: filteredSlides);

          await box.put(key, selectedPresentation.value);
          update(); // TODO: Consider adding a more descriptive method name.
        }
      }
    } catch (e) {
      // TODO: Add logging or some sort of error handling here.
    } finally {
      box?.close();
    }
  }

  /// Deletes all slides from the selected presentation.
  ///
  /// @return {Future<void>}
  Future<void> deleteAllSlidesFromPresentation() async {
    Box<Presentation>? box;

    try {
      box = await Hive.openBox<Presentation>('presentations');

      if (selectedPresentation.value.key != null) {
        int? key = findIndexByValue(box, selectedPresentation.value.key);

        if (key != null) {
          List<Slide> filteredSlidesList = [];

          RxList<Slide> filteredSlides = RxList<Slide>.from(filteredSlidesList);

          Presentation currentPresentation = selectedPresentation.value;

          selectedPresentation.value = Presentation(
              key: currentPresentation.key,
              image: currentPresentation.image,
              name: currentPresentation.name,
              date: currentPresentation.date,
              preacher: currentPresentation.preacher,
              topic: currentPresentation.topic,
              slides: filteredSlides);

          await box.put(key, selectedPresentation.value);
          update();
        }
      }
    } catch (e) {
      // TODO: Add logging or some sort of error handling.
    } finally {
      box?.close();
    }
  }

  /// Deletes the selected presentation.
  ///
  /// @return {Future<void>}
  Future<void> deletePresentation() async {
    Box<Presentation>? box;
    try {
      box = await Hive.openBox<Presentation>('presentations');

      int? keyIndex = findIndexByValue(box, key.value);

      if (keyIndex != null) {
        box.deleteAt(keyIndex);
        presentations.value = box.values.toList().reversed.toList();

        if (key.value == selectedPresentation.value.key) {
          selectedPresentation.value = Presentation(
            key: "",
            image: "",
            name: "",
            date: DateTime.now(),
            preacher: "",
            topic: "",
            slides: RxList<Slide>([]),
          );
          // Assuming you have an empty constructor
        }

        resetValues(100);
      }
    } catch (e) {
      // TODO: Add logging or some sort of error handling.
    } finally {
      box?.close();
    }
  }

  /// Handles a double-tap event on an item.
  ///
  /// @param {int} index - Index of the tapped item.
  /// @param {double} height - Height of the item.
  void doubleTapItem(int index, double height) {
    heightItem.value = height;
    topic.value = presentations[index].topic;
    preacher.value = presentations[index].preacher;
    image.value = presentations[index].image;
    date.value = presentations[index].date;
    id.value = index;
    key.value = presentations[index].key;
    isSaving.value = false;
  }

  /// Initializes the controller.
  ///
  /// @override
  void onInit() {
    super.onInit();
    getAllPresentations(); // Assuming this method is already defined.
  }

  /// Finds the index of a presentation in a Hive box by its key.
  ///
  /// @param {Box<Presentation>} box - The Hive box containing presentations.
  /// @param {String} targetKey - The key of the target presentation.
  /// @return {int?} - The index of the presentation, or null if not found.
  int? findIndexByValue(Box<Presentation> box, String targetKey) {
    var presentationsList = box.values.toList();

    int index = presentationsList
        .indexWhere((presentation) => presentation.key == targetKey);

    return index != -1 ? index : null;
  }

  /// Adds an empty presentation to the list of presentations.
  ///
  /// @return {Future<void>}
  Future<void> addEmptyPresentation() async {
    Box<Presentation>? box;
    try {
      box = await Hive.openBox<Presentation>('presentations');
      final uniqueKey = Uuid().v4();
      DateTime currentDate = DateTime.now();

      var newPresentation = Presentation(
        key: uniqueKey,
        image: "",
        name: "New Presentation",
        date: currentDate,
        preacher: "",
        topic: "New Presentation",
        slides: RxList<Slide>([]),
      );

      // Update selected item and presentation values
      selectedItem.value = uniqueKey;
      selectedPresentation.value = newPresentation;

      await box.put(box.length, newPresentation);
      presentations.value = box.values.toList().reversed.toList();
    } catch (e) {
      // TODO: Add logging or some sort of error handling.
    } finally {
      await box?.close();
    }
  }

  /// Saves the current presentation data.
  ///
  /// @return {Future<void>}
  Future<void> savePresentation() async {
    Box<Presentation>? box;
    try {
      box = await Hive.openBox<Presentation>('presentations');

      DateTime currentDate = isSaving.value ? DateTime.now() : date.value;

      var updatedPresentation = Presentation(
        key: key.value,
        image: image.value,
        name: name.value,
        date: currentDate,
        preacher: preacher.value,
        topic: topic.value,
        slides: RxList<Slide>([]),
      );

      if (isSaving.value) {
        await box.put(box.length, updatedPresentation);
      } else {
        int? existingKeyIndex = findIndexByValue(box, key.value);
        if (existingKeyIndex != null) {
          await box.put(existingKeyIndex, updatedPresentation);
        }
      }

      presentations.value = box.values.toList().reversed.toList();
    } catch (e) {
      // TODO: Add logging or some sort of error handling.
    } finally {
      await box?.close();
    }
  }

  /// Retrieves all presentations and updates the list.
  ///
  /// @return {Future<void>}
  Future<void> getAllPresentations() async {
    Box<Presentation>? box;
    try {
      box = await Hive.openBox<Presentation>('presentations');

      presentations.value = box.values.toList().reversed.toList();

      if (presentations.value.isNotEmpty) {
        await selectItem(presentations.value[0].key);
      }
    } catch (e) {
      // TODO: Add logging or some sort of error handling.
    } finally {
      await box?.close();
    }
  }
}
