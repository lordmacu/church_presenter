import 'dart:convert';

import 'package:get/get.dart';
import 'package:ipuc/app/controllers/present_controller.dart';
import 'package:ipuc/app/controllers/slide_controller.dart';
import 'package:ipuc/models/slide.dart';
import 'package:ipuc/models/song.dart';
import 'package:ipuc/models/songdb.dart';
import 'package:uuid/uuid.dart';
import 'package:diacritic/diacritic.dart';

/// `SongListController` manages the list of songs, search functionality,
/// and interaction with other controllers like `PresentController` and `SliderController`.
class SongListController extends GetxController {
  // Observables to hold the index of the selected song and the search query.
  var selectedIndex = 0.obs;
  var searchQuery = "".obs;

  // Controllers for presentation and slides.
  final PresentController controllerPresent = Get.put(PresentController());
  final SliderController controllerSlide = Get.put(SliderController());

  // Observables to hold the list of songs and songs from the database.
  RxList<Song> songs = <Song>[].obs;
  RxList<SongDb> songsdb = <SongDb>[].obs;

  /// Loads the first 50 songs from the database.
  void loadSongs() async {
    List<SongDb> matchingSongs = await SongDb.getFirst50Songs();
    songsdb.assignAll(matchingSongs);
  }

  /// Searches songs in the database based on the given query.
  ///
  /// @param query - The query string to search for.
  Future<void> searchSongs(String query) async {
    List<SongDb> matchingSongs = await SongDb.searchSongs(query);
    songsdb.assignAll(matchingSongs);
  }

  /// Builds a searchable text for a given song by combining title and paragraphs.
  ///
  /// @param song - The song for which to build the searchable text.
  /// @return String - A searchable string.
  String buildSearchableText(Song song) {
    String allText =
        song.title + " " + song.paragraphs.join(" ").replaceAll('\n', ' ');
    return removeDiacritics(allText.toLowerCase());
  }

  /// Checks if a text matches a given query.
  ///
  /// @param text - The text to check.
  /// @param query - The query string to search for.
  /// @return bool - True if the text contains the query, false otherwise.
  bool isMatch(String text, String query) {
    return text.contains(query);
  }

  /// Adds a new song to the presentation.
  ///
  /// @param song - The song to be added.
  void addNewSong(SongDb song) async {
    // Check if there's an empty presentation, if so, create one
    if (controllerPresent.selectedPresentation.value.key == "") {
      await controllerPresent.addEmptyPresentation();
    }
    // Fetch a random image to be used in the slide
    String? image = await controllerSlide.getRandomImage();

    int index = 0;

    // Add each paragraph of the song as a separate slide
    for (var paragraph in song.paragraphs) {
      var uuid = const Uuid();
      final uniqueKey = uuid.v4();
      final payload = jsonEncode({
        "type": "song",
        "paragraph": '$paragraph',
        "title": song.title,
      });

      Slide slide = Slide(
          key: uniqueKey,
          type: "song",
          dataType: "image",
          dataTypePath: image!,
          dataTypeMode: "cover",
          json: payload);

      // Add the slide to the presentation
      controllerPresent.setSlideToPresentation(slide);

      // Set the first slide as the selected slide
      if (index == 0) {
        controllerPresent.selectedSlide.value = slide;
        controllerSlide.selectedItem.value = slide.key;
      }
      index++;
    }

    // Send the first paragraph to the presentation
    final firstParagraphPayload = jsonEncode({
      "type": "song",
      "paragraph": '${song.paragraphs[0]}',
      "title": song.title,
    });
    await controllerPresent.sendDataToPresentation(firstParagraphPayload);
  }

  /// Overrides the `onInit` lifecycle method to load songs when the controller is initialized.
  @override
  void onInit() {
    super.onInit();
    loadSongs();
  }
}
