import 'dart:convert';

import 'package:get/get.dart';
import 'package:ipuc/app/controllers/present_controller.dart';
import 'package:ipuc/app/controllers/slide_controller.dart';
import 'package:ipuc/models/slide.dart';
import 'package:ipuc/services/verse_service.dart';
import 'package:uuid/uuid.dart';

class DescriptionChapterController extends GetxController {
  var selectedIndex = 0.obs;
  var searchQuery = "".obs;
  var selectedVersion = "rvr1960".obs;
  final PresentController controllerPresent = Get.put(PresentController());
  final SliderController controllerSlide = Get.find();

  RxList<Map<String, dynamic>> versesWithRelations = RxList([]);

  var versions = <String>[].obs;

  void loadVerses() async {
    versesWithRelations.clear();
    // Asume que VersiculoService ya tiene la función getAllVersesWithRelations

    versions.value = await VerseService().getAllUniqueVersions();

    List<Map<String, dynamic>> allVerses =
        await VerseService().getAllVersesWithRelations(versions.value[0]);

    versesWithRelations.assignAll(allVerses);
  }

  void updateSearch(String query) async {
    searchQuery.value = query;
    versesWithRelations.clear();

    if (searchQuery.value.isNotEmpty) {
      List<Map<String, dynamic>> allVerses =
          await VerseService().searchVerses(query, selectedVersion.value);
      versesWithRelations.assignAll(allVerses);
    } else {
      loadVerses();
    }
  }

  loadBibleByVersion() async {
    versesWithRelations.clear();

    List<Map<String, dynamic>> allVerses =
        await VerseService().getAllVersesWithRelations(selectedVersion.value);
    versesWithRelations.assignAll(allVerses);
  }

  void addNewVerse(
      int verse, String verseText, String book, int chapter) async {
    if (controllerPresent.selectPresentation.value.key == "") {
      await controllerPresent.addEmptyPresentation();
    }

    var uuid = const Uuid();
    final uniqueKey = uuid.v4();

    final payload = jsonEncode({
      "type": "verse",
      "verseText": verseText,
      "book": book,
      "testament": "",
      "chapter": chapter,
      "verse": verse,
    });
    String? image = await controllerSlide.getRandomImage();

    controllerPresent.setSlideToPresentation(Slide(
        key: uniqueKey,
        type: "verse",
        dataType: "image",
        dataTypePath: image!,
        dataTypeMode: "cover",
        json: payload));
  }

  void addEmptyPresentationImage() async {
    String? image = await controllerSlide.getRandomImage();

    var uuid = const Uuid();
    final uniqueKey = uuid.v4();
    final payload = jsonEncode({"type": "image", "path": image});

    controllerPresent.setSlideToPresentation(Slide(
        key: uniqueKey,
        type: "image",
        dataType: "image",
        dataTypePath: image!,
        dataTypeMode: "cover",
        json: payload));

    controllerPresent.selectSlide.value = Slide(
        key: uniqueKey,
        type: "image",
        dataType: "image",
        dataTypePath: image,
        dataTypeMode: "cover",
        json: payload);
  }

  void sendDirectToPresentation(
      int verse, String verseText, String book, int chapter) async {
    final payload = jsonEncode({
      "type": "verse",
      "verseText": verseText,
      "book": book,
      "testament": "",
      "chapter": chapter,
      "verse": verse,
    });

    await controllerPresent.sendToPresentation(payload);
  }

  @override
  void onInit() {
    super.onInit();
    loadVerses();
  }
}
