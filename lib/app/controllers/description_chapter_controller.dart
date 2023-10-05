import 'dart:convert';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/present_controller.dart';
import 'package:ipuc/app/controllers/slide_controller.dart';
import 'package:ipuc/models/slide.dart';
import 'package:ipuc/services/verse_service.dart';
import 'package:uuid/uuid.dart';

/// Manages the description and details of chapters and verses
class DescriptionChapterController extends GetxController {
  /// The currently selected index in the verse list
  final selectedIndex = 0.obs;

  /// Query used for searching verses
  final searchQuery = ''.obs;

  /// The selected Bible version
  final selectedVersion = 'rvr1960'.obs;

  /// Instance of the PresentController
  final PresentController controllerPresent = Get.put(PresentController());

  /// Instance of the SliderController
  final SliderController controllerSlide = Get.find();

  /// List of verses with their respective relations
  final RxList<Map<String, dynamic>> versesWithRelations = RxList([]);

  /// List of available versions
  final versions = <String>[].obs;

  /// Initializes the controller
  @override
  void onInit() {
    super.onInit();
    loadVerses();
  }

  /// Loads verses from the database.
  ///
  /// Updates the `versesWithRelations` observable list.
  Future<void> loadVerses() async {
    versesWithRelations.clear();
    versions.value = await VerseService().getAllUniqueVersions();
    final allVerses =
        await VerseService().getAllVersesWithRelations(versions.value[0]);
    versesWithRelations.assignAll(allVerses);
  }

  /// Updates the search query and triggers a new search.
  ///
  /// * [query]: The search term.
  ///
  /// Updates the `versesWithRelations` observable list based on the search query.
  Future<void> updateSearch(String query) async {
    searchQuery.value = query;
    versesWithRelations.clear();

    if (searchQuery.value.isNotEmpty) {
      final allVerses =
          await VerseService().searchVerses(query, selectedVersion.value);
      versesWithRelations.assignAll(allVerses);
    } else {
      loadVerses();
    }
  }

  /// Loads the Bible verses based on the selected version.
  ///
  /// Updates the `versesWithRelations` observable list based on the selected Bible version.
  Future<void> loadBibleByVersion() async {
    versesWithRelations.clear();
    final allVerses =
        await VerseService().getAllVersesWithRelations(selectedVersion.value);
    versesWithRelations.assignAll(allVerses);
  }

  /// Adds a new verse to the presentation.
  ///
  /// * [verse]: The verse number.
  /// * [verseText]: The text of the verse.
  /// * [book]: The book where the verse is located.
  /// * [chapter]: The chapter where the verse is located.
  ///
  /// A new slide is added to the presentation.
  Future<void> addNewVerse(
      int verse, String verseText, String book, int chapter) async {
    if (controllerPresent.selectedPresentation.value.key == '') {
      await controllerPresent.addEmptyPresentation();
    }

    final uniqueKey = const Uuid().v4();

    final payload = jsonEncode({
      'type': 'verse',
      'verseText': verseText,
      'book': book,
      'testament': '',
      'chapter': chapter,
      'verse': verse,
    });
    final image = await controllerSlide.getRandomImage();

    controllerPresent.setSlideToPresentation(Slide(
        key: uniqueKey,
        type: 'verse',
        dataType: 'image',
        dataTypePath: image!,
        dataTypeMode: 'cover',
        json: payload));
  }

  /// Adds an empty presentation slide with an image.
  ///
  /// A new empty slide with an image is added to the presentation.
  Future<void> addEmptyPresentationImage() async {
    final image = await controllerSlide.getRandomImage();
    final uniqueKey = const Uuid().v4();

    final payload = jsonEncode({'type': 'image', 'path': image});

    controllerPresent.setSlideToPresentation(Slide(
        key: uniqueKey,
        type: 'image',
        dataType: 'image',
        dataTypePath: image!,
        dataTypeMode: 'cover',
        json: payload));

    controllerPresent.selectedSlide.value = Slide(
        key: uniqueKey,
        type: 'image',
        dataType: 'image',
        dataTypePath: image,
        dataTypeMode: 'cover',
        json: payload);
  }

  /// Sends the selected verse directly to the presentation.
  ///
  /// * [verse]: The verse number.
  /// * [verseText]: The text of the verse.
  /// * [book]: The book where the verse is located.
  /// * [chapter]: The chapter where the verse is located.
  ///
  /// Sends the verse directly to the current presentation.
  Future<void> sendDirectToPresentation(
      int verse, String verseText, String book, int chapter) async {
    final payload = jsonEncode({
      'type': 'verse',
      'verseText': verseText,
      'book': book,
      'testament': '',
      'chapter': chapter,
      'verse': verse,
    });

    await controllerPresent.sendDataToPresentation(payload);
  }
}
