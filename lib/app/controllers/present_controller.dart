import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:ipuc/models/presentation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ipuc/models/slide.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:uuid/uuid.dart';

class PresentController extends GetxController {
  var selectedItem = RxString("");
  var heightItem = RxDouble(0.0);
  var topic = RxString("");
  var key = RxString("");
  var preacher = RxString("");
  var image = RxString("");
  var name = RxString("");
  var isSaving = RxBool(false);
  var date = Rx<DateTime>(DateTime.now());
  var id = RxInt(0);

  var isPanelOpen = false.obs;
  var selectPresentation = Presentation(
    key: "",
    image: "",
    name: "",
    date: DateTime.now(),
    preacher: "",
    topic: "",
    slides: RxList<Slide>([]),
  ).obs;

  var selectSlide = Slide(
          key: "",
          type: "",
          dataType: "",
          json: "",
          dataTypePath: "",
          dataTypeMode: "cover")
      .obs;
  RxList<Presentation> presentations = RxList<Presentation>();

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Guardar la imagen en el sistema de archivos del app
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final File savedImage =
          await File(pickedFile.path).copy('${directory.path}/$fileName');

      image.value = savedImage.path; // Guardar la ruta de la imagen
    }
  }

  sendToViewer() async {
    try {
      final subWindowIds = await DesktopMultiWindow.getAllSubWindowIds();

      final payload = jsonEncode(selectSlide.value.json);

      final payloaDataType = jsonEncode({
        "dataType": selectSlide.value.dataType,
        "dataTypePath": selectSlide.value.dataTypePath,
        "dataTypeMode": selectSlide.value.dataTypeMode,
      });

      final setDataType = await DesktopMultiWindow.invokeMethod(
          subWindowIds[0], "send_data_type", payloaDataType);
    } catch (e) {}
  }

  void resetValues(double height) async {
    heightItem.value = height;
    topic.value = "";
    preacher.value = "";
    image.value = "";
    id.value = 0;
  }

  Future selectItem(String key) async {
    selectedItem.value = key;
    Box<Presentation>? box;

    box = await Hive.openBox<Presentation>('presentations');
    var presentationsList = box.values.toList();

    int index =
        presentationsList.indexWhere((presentation) => presentation.key == key);

    if (index != -1) {
      // Asigna el Presentation correspondiente a tu variable observable
      selectPresentation.value = presentationsList[index];
    } else {}

    try {} catch (e) {
    } finally {
      box?.close();
    }
  }

  void setSlideToPresentation(Slide newSlide) async {
    Box<Presentation>? box;

    try {
      box = await Hive.openBox<Presentation>('presentations');

      // Asegúrate de que selectPresentation está inicializado y tiene un key válido.
      if (selectPresentation.value.key != null) {
        // Encuentra la clave en la box de Hive.
        int? key = findIndexByValue(box, selectPresentation.value.key!);

        if (key != null) {
          // Actualiza la lista de slides en el objeto selectPresentation
          selectPresentation.value.slides.add(newSlide);

          // Actualiza la box de Hive con el objeto selectPresentation modificado.
          await box.put(key, selectPresentation.value);
          update();
        } else {}
      } else {}
    } catch (e) {
    } finally {
      box?.close();
    }
  }

  Future deleteSlideToPresentation(String slideKey) async {
    Box<Presentation>? box;

    try {
      box = await Hive.openBox<Presentation>('presentations');

      // Asegúrate de que selectPresentation está inicializado y tiene un key válido.
      if (selectPresentation.value.key != null) {
        // Encuentra la clave en la box de Hive.
        int? key = findIndexByValue(box, selectPresentation.value.key!);

        if (key != null) {
          List<Slide> filteredSlidesList = selectPresentation.value.slides
              .where((slide) => slide.key != slideKey)
              .toList(); // Convert to List<Slide>

          RxList<Slide> filteredSlides = RxList<Slide>.from(
              filteredSlidesList); // Convert to RxList<Slide>

          Presentation currentPresentation = selectPresentation.value;

          selectPresentation.value = Presentation(
              key: currentPresentation.key,
              image: currentPresentation.image,
              name: currentPresentation.name,
              date: currentPresentation.date,
              preacher: currentPresentation.preacher,
              topic: currentPresentation.topic,
              slides: filteredSlides // Assign the filtered RxList here
              );

          await box.put(key, selectPresentation.value);
          update();
        } else {}
      } else {}
    } catch (e) {
    } finally {
      box?.close();
    }
  }

  Future deleteAllSlideToPresentation() async {
    Box<Presentation>? box;

    try {
      box = await Hive.openBox<Presentation>('presentations');

      // Asegúrate de que selectPresentation está inicializado y tiene un key válido.
      if (selectPresentation.value.key != null) {
        // Encuentra la clave en la box de Hive.
        int? key = findIndexByValue(box, selectPresentation.value.key!);

        if (key != null) {
          List<Slide> filteredSlidesList = []; // Convert to List<Slide>

          RxList<Slide> filteredSlides = RxList<Slide>.from(
              filteredSlidesList); // Convert to RxList<Slide>

          Presentation currentPresentation = selectPresentation.value;

          selectPresentation.value = Presentation(
              key: currentPresentation.key,
              image: currentPresentation.image,
              name: currentPresentation.name,
              date: currentPresentation.date,
              preacher: currentPresentation.preacher,
              topic: currentPresentation.topic,
              slides: filteredSlides // Assign the filtered RxList here
              );

          await box.put(key, selectPresentation.value);
          update();
        } else {}
      } else {}
    } catch (e) {
    } finally {
      box?.close();
    }
  }

  void deletePresentation() async {
    Box<Presentation>? box;
    try {
      box = await Hive.openBox<Presentation>('presentations');

      int? keyString = findIndexByValue(box, key.value);
      box.deleteAt(keyString!);

      presentations.value = box.values.toList().reversed.toList();
      if (key.value == selectPresentation.value.key) {
        selectPresentation.value = Presentation(
          key: "",
          image: "",
          name: "",
          date: DateTime.now(),
          preacher: "",
          topic: "",
          slides: RxList<Slide>([]),
        );
      }

      box.close();
    } catch (e) {
      // Manejar errores aquí
    } finally {
      box?.close();

      // Restablece las variables después de borrar el elemento
      resetValues(100);
    }
  }

  void doubleTapItem(int index, double height) {
    heightItem.value = heightItem
        .value; // Asumiendo que ya tienes este valor correctamente configurado
    topic.value = presentations[index].topic;
    preacher.value = presentations[index].preacher;
    image.value = presentations[index].image;
    date.value = presentations[index].date;
    date.value = presentations[index].date;
    id.value = index;
    key.value = presentations[index].key;
    isSaving.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    getAllPresentations();
  }

  int? findIndexByValue(Box<Presentation> box, String targetKey) {
    var presentationsList = box.values.toList();

    int index = presentationsList
        .indexWhere((presentation) => presentation.key == targetKey);

    if (index != -1) {
      return index; // Devuelve el índice del elemento que coincide
    }

    return null; // Devuelve null si no se encuentra ninguna coincidencia
  }

  Future addEmptyPresentation() async {
    Box<Presentation>? box;
    try {
      box = await Hive.openBox<Presentation>('presentations');
      var uuid = Uuid();
      final uniqueKey = uuid.v4();
      DateTime currentDate = DateTime
          .now(); // Actualiza la fecha solo si es una nueva presentación

      var presentation = Presentation(
        key: uniqueKey,
        image: "",
        name: "Nueva presentación",
        date: currentDate,
        preacher: "",
        topic: "Nueva presentación",
        slides: RxList<Slide>([]),
      );
      selectedItem.value = uniqueKey;

      selectPresentation.value = presentation;

      final newId = box.length; // Este ID será autoincrementable
      await box.put(newId, presentation);

      presentations.value = box.values.toList().reversed.toList();
    } catch (e) {
      // Manejar errores aquí
    } finally {
      await box?.close();
    }
  }

  void savePresentation() async {
    Box<Presentation>? box;
    try {
      box = await Hive.openBox<Presentation>('presentations');

      DateTime currentDate = isSaving.value
          ? DateTime.now()
          : date.value; // Actualiza la fecha solo si es una nueva presentación

      var presentation = Presentation(
        key: key.value,
        image: image.value,
        name: name.value,
        date: currentDate,
        preacher: preacher.value,
        topic: topic.value,
        slides: RxList<Slide>([]),
      );
      final newId = box.length; // Este ID será autoincrementable

      if (isSaving.value) {
        // Crear un nuevo elemento
        final newId = box.length; // Este ID será autoincrementable
        await box.put(newId, presentation);
      } else {
        await box.put(findIndexByValue(box, key.value), presentation);
      }

      presentations.value = box.values.toList().reversed.toList();
    } catch (e) {
      // Manejar errores aquí
    } finally {
      box?.close();
    }
  }

  void getAllPresentations() async {
    var box = await Hive.openBox<Presentation>('presentations');

    presentations.value = box.values.toList().reversed.toList();

    if (box.values.toList().length > 0) {
      await selectItem(presentations.value[0].key);
    }
    box.close();
  }
}
