import 'dart:io';

import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:youtube_downloader/youtube_downloader.dart';
import 'package:youtube_downloader/youtube_downloader.dart';
import 'package:process_run/shell.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class YoutubeController extends GetxController {
  var searches = [].obs;
  var videoSearchList = null;
  RxDouble downloadProgress = 0.0.obs;
  RxInt page = 0.obs;

  RxList<String> playlists = [
    'PLB05CDwGRRyQjMBkkSzyIcScDD6gver8b',
    "PLyPxk25rtnk8G3NfjIwUfzRUY0woIJCq1",
    "PLB05CDwGRRyROW4wzx1iSOuJTGq54_j_Q",
    "PLGmxyVGSCDKvmLInHxJ9VdiwEb82Lxd2E",
    "PLTDgOUcX23hbq6BR226eSwhvBU86WJUph",
    "PLTDgOUcX23hbq6BR226eSwhvBU86WJUph",
    "PLTDgOUcX23hbmAATluQUP3aZwSXQa01GJ"
  ].obs;
  RxInt currentQuery = 0.obs;
  RxString nextPage = "".obs;

  @override
  void onInit() {
    super.onInit();
  }

  String? extractYouTubeId(String url) {
    RegExp regExp = RegExp(
      r"(?<=watch\?v=)[^&]+",
      caseSensitive: false,
      multiLine: false,
    );

    Match? match = regExp.firstMatch(url);

    return match != null ? match.group(0) : null;
  }

  int convertToDuration(String time) {
    final parts = time.split(':');
    if (parts.length != 2) {
      return 0; // Retorna una duración de 0 si el formato no es válido
    }

    final minutes = int.tryParse(parts[0]) ?? 0;
    final seconds = int.tryParse(parts[1]) ?? 0;

    return Duration(seconds: (minutes * 60) + seconds).inSeconds;
  }

  Future getNextYoutubeVideos() async {
    String query = (playlists.value[currentQuery.value]);

    final Uri uri =
        Uri.https('pipedapi.kavin.rocks', '/nextpage/playlists/${query}', {
      'nextpage': Uri.decodeComponent(nextPage.value.replaceAll("\\", "")),
    });

    final String url = uri.toString();

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Accept-Encoding": "gzip",
      },
    );

    try {
      final results = jsonDecode(response.body);

      nextPage.value = Uri.encodeComponent(results["nextpage"]);

      for (var search in results["relatedStreams"]) {
        String? youTubeId = extractYouTubeId(search["url"]);

        searches.add({
          "videoId": youTubeId,
          "title": "${search["title"]}",
          "thumbnail": search["thumbnail"],
        });
        searches.refresh;
      }

      if (results["nextpage"] != null) {
        nextPage.value = Uri.encodeComponent(results["nextpage"]);
      } else {
        nextPage.value = "";
        currentQuery.value = currentQuery.value + 1;
        getYoutubeVideos();
      }
    } catch (e) {
      nextPage.value = "";
      currentQuery.value = currentQuery.value + 1;
      getYoutubeVideos();
    }

    update();
  }

  Future getYoutubeVideos() async {
    String query = (playlists.value[currentQuery.value]);

    final Uri uri = Uri.https('pipedapi.kavin.rocks', '/playlists/${query}');

    final String url = uri.toString();

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Accept": "application/json",
        "Accept-Encoding": "gzip",
      },
    );

    final results = jsonDecode(response.body);

    for (var search in results["relatedStreams"]) {
      var url = search["url"].split("v=");

      searches.add({
        "videoId": url[1],
        "title": "${search["title"]}",
        "thumbnail": search["thumbnail"],
      });
      searches.refresh;
    }
    if (results["nextpage"] != null) {
      nextPage.value = Uri.encodeComponent(results["nextpage"]);
    } else {
      nextPage.value = "";
      currentQuery.value = currentQuery.value + 1;
      getYoutubeVideos();
    }

    update();
  }

  Future<String> downloadVideo(String videoId) async {
    final programFilesPath = Platform.environment['ProgramFiles'];
    final ytdlpFolder = '$programFilesPath\\ipuc\\bin';
    final ffmpegPath = '$programFilesPath\\ipuc\\ffmpeg\\bin';

    // Obtener el directorio de documentos
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final ipucVideosDirectory = Directory('${appDocDir.path}\\ipucVideos');

    // Crear el directorio 'ipucVideos' si no existe
    if (!await ipucVideosDirectory.exists()) {
      await ipucVideosDirectory.create();
    }

    // Generar un nombre de archivo único usando el ID del video y un timestamp
    final fileName = "$videoId-${DateTime.now().millisecondsSinceEpoch}.mp4";
    final fullPath = '${ipucVideosDirectory.path}\\$fileName';

    var shell = Shell();

    // Descargar el video
    await shell.run('''
    "$ytdlpFolder\\yt-dlp.exe" -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4'  --ffmpeg-location "$ffmpegPath\\ffmpeg.exe" -o '$fullPath' https://www.youtube.com/watch?v=$videoId
  ''');

    return fullPath;
  }
}
