import 'dart:convert';
import 'dart:ffi';

import 'package:get/get.dart';
import 'package:ipuc/app/controllers/present_controller.dart';
import 'package:ipuc/app/controllers/slide_controller.dart';
import 'package:ipuc/core/sqlite_helper.dart';
import 'package:ipuc/models/slide.dart';
import 'package:ipuc/models/song.dart';
import 'package:ipuc/models/songdb.dart';
import 'package:uuid/uuid.dart';
import 'package:diacritic/diacritic.dart';

/// `SongController` manages the list of songs, search functionality,
/// and interaction with other controllers like `PresentController` and `SliderController`.
class SongController extends GetxController {
  // Observables to hold the index of the selected song and the search query.
  var selectedIndex = 0.obs;
  var searchQuery = "".obs;

  Rx<SongDb> currentSong = SongDb(
          title: "",
          youtubeUrl: "",
          paragraphs: [],
          videoExplanation: [],
          searchableText: "",
          lyricsPlain: "")
      .obs;

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
  void addNewSongToPresenter(SongDb song) async {
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

  /// Resets the [currentSong] to an empty [SongDb] object.
  ///
  /// This is used to clear the current song data when needed.
  Future<void> resetSong() async {
    currentSong.value = SongDb(
        title: "",
        youtubeUrl: "",
        paragraphs: [],
        videoExplanation: [],
        searchableText: "",
        lyricsPlain: "");
  }

  /// Inserts a new song into the database.
  ///
  /// The method first checks if a song with the same searchable title
  /// already exists. If not, it inserts a new song with details
  /// such as title, YouTube URL, paragraphs, etc.
  Future<void> addNewDbSong() async {
    final ipucDb = await DatabaseHelper().db;
    if (ipucDb == null) {
      return;
    }

    List<dynamic> paragraphs = currentSong.value.paragraphs;
    String cleanTitle = currentSong.value.title;

    String searchableText = removeDiacritics(
        (cleanTitle + " " + paragraphs.join(" ")).replaceAll('\n', ' '));

    List<Map> existingSongs = await ipucDb.query('songs',
        where: 'searchableTitle = ?',
        whereArgs: [removeDiacritics(cleanTitle)]);

    if (existingSongs.isEmpty) {
      await ipucDb.insert('songs', {
        'title': cleanTitle,
        'youtubeUrl': currentSong.value.youtubeUrl,
        'paragraphs': jsonEncode(paragraphs),
        'lyricsPlain': jsonEncode(paragraphs),
        'videoExplanation': jsonEncode([]),
        'searchableText': searchableText,
        'searchableTitle': removeDiacritics(cleanTitle)
      });
    }
  }

  /// Updates an existing song in the database.
  ///
  /// It updates the details of the song such as title, YouTube URL,
  /// paragraphs, etc., based on the ID of the [currentSong].
  ///
  /// After the update operation, it resets the [currentSong] to empty.
  Future<void> updateDbSong() async {
    List<dynamic> paragraphs = currentSong.value.paragraphs;
    final ipucDb = await DatabaseHelper().db;

    if (ipucDb == null) {
      return;
    }

    String cleanTitle = currentSong.value.title;
    String searchableText = removeDiacritics(
        (cleanTitle + " " + paragraphs.join(" ")).replaceAll('\n', ' '));

    await ipucDb.update(
      'songs',
      {
        'title': cleanTitle,
        'youtubeUrl': currentSong.value.youtubeUrl,
        'paragraphs': jsonEncode(paragraphs),
        'lyricsPlain': jsonEncode(paragraphs),
        'videoExplanation': jsonEncode([]),
        'searchableText': searchableText,
        'searchableTitle': removeDiacritics(cleanTitle),
      },
      where: 'id = ?',
      whereArgs: [currentSong.value.id],
    );

    resetSong();
  }

  /// Overrides the `onInit` lifecycle method to load songs when the controller is initialized.
  @override
  void onInit() {
    super.onInit();
    loadSongs();
  }
}
