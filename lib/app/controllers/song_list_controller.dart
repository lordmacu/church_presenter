import 'dart:convert';

import 'package:get/get.dart';
import 'package:ipuc/app/controllers/present_controller.dart';
import 'package:ipuc/app/controllers/slide_controller.dart';
import 'package:ipuc/models/slide.dart';
import 'package:ipuc/models/song.dart';
import 'package:ipuc/models/songdb.dart';
import 'package:uuid/uuid.dart';
import 'package:diacritic/diacritic.dart';

class SongListController extends GetxController {
  var selectedIndex = 0.obs;
  var searchQuery = "".obs;
  final PresentController controllerPresent = Get.put(PresentController());
  final SliderController controllerSlide = Get.put(SliderController());

  RxList<Song> songs = <Song>[].obs;
  RxList<SongDb> songsdb = <SongDb>[].obs;

  void loadSongs() async {
    List<SongDb> matchingSongs = await SongDb.getFirst50Songs();

    songsdb.assignAll(matchingSongs);
  }

  Future<void> searchSongs(String query) async {
    List<SongDb> matchingSongs = await SongDb.searchSongs(query);
    songsdb.assignAll(matchingSongs);
  }

  String buildSearchableText(Song song) {
    String allText =
        song.title + " " + song.paragraphs.join(" ").replaceAll('\n', ' ');
    return removeDiacritics(allText.toLowerCase());
  }

  bool isMatch(String text, String query) {
    return text.contains(query);
  }

  void addNewSong(SongDb song) async {
    if (controllerPresent.selectedPresentation.value.key == "") {
      await controllerPresent.addEmptyPresentation();
    }
    String? image = await controllerSlide.getRandomImage();

    int index = 0;

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
      controllerPresent.setSlideToPresentation(slide);

      if (index == 0) {
        controllerPresent.selectedSlide.value = slide;
        controllerSlide.selectedItem.value = slide.key;
      }
      index++;
    }
    final firstParagraphPayload = jsonEncode({
      "type": "song",
      "paragraph": '${song.paragraphs[0]}',
      "title": song.title,
    });

    await controllerPresent.sendDataToPresentation(firstParagraphPayload);
  }

  @override
  void onInit() {
    super.onInit();
    loadSongs();
  }
}
