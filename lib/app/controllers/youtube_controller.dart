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
import 'package:translator/translator.dart';
import 'package:diacritic/diacritic.dart';

class YoutubeController extends GetxController {
  var searches = [].obs;
  var videoSearchList = null;
  RxDouble downloadProgress = 0.0.obs;
  RxInt page = 0.obs;

  RxList<String> playlists = [
    "PLB05CDwGRRyQjMBkkSzyIcScDD6gver8b",
    "PLyPxk25rtnk8G3NfjIwUfzRUY0woIJCq1",
    "PLB05CDwGRRyROW4wzx1iSOuJTGq54_j_Q",
    "PLGmxyVGSCDKvmLInHxJ9VdiwEb82Lxd2E",
    "PLTDgOUcX23hbq6BR226eSwhvBU86WJUph",
    "PLTDgOUcX23hbmAATluQUP3aZwSXQa01GJ",
    "PLTDgOUcX23hYtbVYnLH0oRs7GK9IWG99a",
    "PLB05CDwGRRyScXQ8JC-Sib5cq8vLn0Z2T",
    "PLQsl3b_YTo_RLGSQx8qCw6NJDdUwcZO-n",
    "PLB05CDwGRRyTgfEGONWJr62eqCShpp8XG",
    "PLhsGWuiKYZ6Vs6xYBzYx4a2V058WC5f_P",
    "PLcrJvksqu2eg-e5mGapirveuplQQr3uR8",
    "PLPvz_riaDsvjpcTqQcUulWbEeMcY_EyMQ",
    "PLyPxk25rtnk9a5DJOodo-zUyNievhi7ch",
    "PLe_K-a-dCP_xszYesrvobClbRM7p_RV1N",
    "PLNn1Mqi8006H_TtCWMFe417sITdS6-0jE",
    "PLMX5ZmS3rPRO_SS4DqPu-xUPGQ1tT1vQV",
    "PLMFhMP8mBdxQUadkTZVAL7SRS0mtWftdD",
    "PL6Zhbdr-yQq_ycyjMOzBVKY2_Mg9yXI-5",
    "PLbx6WyCdwgN4SwD8WKRFiianYQvctkoJu",
    "PL55tdNKlI-GBojKRs-n8z7J12VBu3MjUz",
    "PLjXq-tWH_8zi-ggyg4PoS0Fx4VdIid4GZ",
    "PLgfhoph9nAPHUBLqtu65DocBqRd6s3Pm5",
    "PLg8jH2JuGzLjXwS94kAarSBzaHKe0SND8",
    "PLNjtDA4diwJBzxc1S7L8BwrKR0Td1DeQ8",
    "PLsbVFBr5Cf_adc6TwVVTt3Q8qnHVdJlwY",
    "PLHDRho3EQxJgbLmZu16c_Tr9XCoZZM2fT",
    "PLdGJJ6BBahVodCt3Cet2bDmDSiRVJoE5G",
    "PLaTP_B8K0vdiUP8f3h6Y2930CJS4e_e4H",
    "PL4jjgxHdfmYabCPLJQCRwOw4oZ0TXuz1k",
    "PLB05CDwGRRyT6lCeC4dJI3p1LM1Frhh82",
    "PLDTG-mhC5UzPo-QFAg7dXbJUVtRCjUN6J",
    "PLTNJfMslLvloODAsi9g3GV7iplOfD-ITg",
    "PLLBWNs6n7YMXx5z7pEWZlu-2rZQ5bfOiq"
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

    listChannelVideos(query);

    update();
  }

  Future<void> deleteErrorVideoId(String errorId) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final ipucVideosDirectory = Directory('${appDocDir.path}\\ipucVideos');
    final filePath = '${ipucVideosDirectory.path}\\ids.txt';

    // Lee el contenido del archivo y lo divide en una lista de líneas
    final List<String> lines = await File(filePath).readAsLines();

    // Elimina la línea que contiene el id de error
    lines.removeWhere((line) => line == errorId);

    // Escribe la lista de nuevo al archivo
    await File(filePath).writeAsString(lines.join('\n'));
  }

  Future<void> getYoutubeVideos() async {
    final translator = GoogleTranslator();

    var shell = Shell();
    final programFilesPath = Platform.environment['ProgramFiles'];
    final ytdlpFolder = '$programFilesPath\\ipuc\\bin';
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final ipucVideosDirectory = Directory('${appDocDir.path}\\ipucVideos');

    final filePath = '${ipucVideosDirectory.path}\\ids.txt';

    // Leer el archivo en una cadena
    final String fileContent = await File(filePath).readAsString();

    // Dividir la cadena en líneas para obtener las IDs individuales
    final List<String> videoIds = fileContent.split('\n');

    // Eliminar líneas vacías, si las hay
    final List<String> cleanedVideoIds =
        videoIds.where((line) => line.isNotEmpty).toList();

    // Crear una lista de mapas con los IDs
    final List<Map<String, String>> jsonArray =
        cleanedVideoIds.map((id) => {'videoId': id}).toList();

    // Convertir la lista de mapas a una cadena JSON
    final String jsonOutput = jsonEncode(jsonArray);

    // Guardar el JSON en un nuevo archivo si lo desea
    final String jsonFilePath = '${appDocDir.path}/videos.json';
    await File(jsonFilePath).writeAsString(jsonOutput);
    print(jsonOutput);

    return;

    // Lee el contenido del archivo y lo divide en una lista de líneas
    final List<String> lines = await File(filePath).readAsLines();

    print("aqui hay tantos ids ${lines.length} ");

    var videoJson = [];
    var countVideos = 0;
    for (var line in lines) {
      try {
        var videoId = line.trim();

        final result = await shell.run('''
      "$ytdlpFolder\\yt-dlp.exe" --skip-download --dump-json "https://www.youtube.com/watch?v=${videoId}"
    ''');

        var jsonResponse = jsonDecode(result.first.stdout);
        if (jsonResponse["duration"] < 250) {
          var arrayTags = jsonResponse["tags"];

          var uploaderId =
              jsonResponse["uploader_id"].replaceAll("@", "").toLowerCase();
          var uploader = jsonResponse["uploader"].toLowerCase();
          var filteredTags = arrayTags
              .where((tag) =>
                  !tag.toLowerCase().contains("easy") &&
                  !tag.toLowerCase().contains(uploaderId) &&
                  !tag.toLowerCase().contains("worship") &&
                  !tag.toLowerCase().contains("autor") &&
                  !tag.toLowerCase().contains(uploader))
              .toList();

          var translation = await translator.translate(filteredTags.join(", "),
              to: 'es', from: "en");

          var videoData = {
            "youtubeId": line,
            "duration": jsonResponse["duration"],
            "sercheableTags":
                "${removeDiacritics(translation.text).toLowerCase()} ${(translation.text).toLowerCase()}"
          };

          videoJson.add(videoData);
          countVideos++;
          print("se proceso el video $countVideos ${videoData}");
        }
      } catch (e) {}
    }
    final jsonString = jsonEncode(videoJson);
    final videoTxtPath = '${ipucVideosDirectory.path}\\videos.txt';
    await File(videoTxtPath).writeAsString(jsonString);
    return;
    String query = playlists.value[currentQuery.value];

    for (var query in playlists) {
      final programFilesPath = Platform.environment['ProgramFiles'];
      final ytdlpFolder = '$programFilesPath\\ipuc\\bin';

      // Obtener el directorio de documentos
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final ipucVideosDirectory = Directory('${appDocDir.path}\\ipucVideos');

      // Crear el directorio 'ipucVideos' si no existe
      if (!await ipucVideosDirectory.exists()) {
        await ipucVideosDirectory.create();
      }

      // Definir la ubicación del archivo 'ids.txt'
      final filePath = '${ipucVideosDirectory.path}\\ids.txt';

      var shell = Shell();

      try {
        final result = await shell.run('''
      "$ytdlpFolder\\yt-dlp.exe" --skip-download --flat-playlist --print id "https://www.youtube.com/playlist?list=$query"
    ''');

        // Obtener la salida y formatearla
        final output =
            result.map((processResult) => processResult.stdout).join(',');

        // Agregar la salida al archivo existente
        await File(filePath).writeAsString(output, mode: FileMode.append);

        // Leer el contenido actualizado del archivo
        final fileContent = await File(filePath).readAsString();
        final videoIds =
            fileContent.split('\n').where((line) => line.isNotEmpty).toList();

        // Crear un array de objetos JSON con los IDs
        final jsonArray = videoIds.map((id) => {'videoId': id.trim()}).toList();

        for (var element in jsonArray) {
          searches.value.add({
            "videoId": element["videoId"],
            "title": element["videoId"],
            "thumbnail":
                "https://img.youtube.com/vi/${element["videoId"]}/sddefault.jpg",
          });
          searches.refresh();
        }
      } catch (e) {
        print("Error: $e");
      }
      await Future.delayed(const Duration(seconds: 2));
    }

    currentQuery.value = currentQuery.value + 1;
    update();
  }

  Future<List<String>> listChannelVideos(String channelId) async {
    final programFilesPath = Platform.environment['ProgramFiles'];
    final ytdlpFolder = '$programFilesPath\\ipuc\\bin';

    var shell = Shell();

    final result = await shell.run('''
    "$ytdlpFolder\\yt-dlp.exe" --skip-download  --flat-playlist --print id "https://www.youtube.com/playlist?list=$channelId"
  ''');

    final List<String> videoIds = [];

    for (var element in result) {
      // Aquí se supone que cada salida estándar contiene un ID de video
      final videoId = element.stdout.trim();
      videoIds.add(videoId);
    }

    return videoIds;
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
