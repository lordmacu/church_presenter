import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:ipuc/app/controllers/present_controller.dart';
import 'package:ipuc/app/controllers/slide_controller.dart';
import 'package:ipuc/models/book.dart';
import 'package:ipuc/models/lyric.dart';
import 'package:ipuc/models/slide.dart';
import 'package:ipuc/models/song.dart';
import 'package:ipuc/models/songdb.dart';
import 'package:ipuc/models/testament.dart';
import 'package:ipuc/models/verse.dart';
import 'package:ipuc/services/verse_service.dart';
import 'package:uuid/uuid.dart';
import 'package:diacritic/diacritic.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:diacritic/diacritic.dart'; // para removeDiacritics

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
    if (controllerPresent.selectPresentation.value.key == "") {
      await controllerPresent.addEmptyPresentation();
    }
    String? image = await controllerSlide.getRandomImage();

    for (var paragraph in song.paragraphs) {
      var uuid = Uuid();
      final uniqueKey = uuid.v4();
      final payload = jsonEncode({
        "type": "song",
        "paragraph": '${paragraph}',
        "title": song.title,
      });

      controllerPresent.setSlideToPresentation(Slide(
          key: uniqueKey,
          type: "song",
          dataType: "image",
          dataTypePath: image!,
          dataTypeMode: "cover",
          json: payload));
    }
    final firstParagraphPayload = jsonEncode({
      "type": "song",
      "paragraph": '${song.paragraphs[0]}',
      "title": song.title,
    });

    await controllerPresent.sendToPresentation(firstParagraphPayload);
  }

  @override
  void onInit() {
    super.onInit();
    loadSongs();
  }
}
