import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:ipuc/app/controllers/argument_controller.dart';
import 'package:ipuc/app/routes/app_pages.dart';
import 'package:ipuc/app/routes/app_routes.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:ipuc/core/sqlite_helper.dart';
import 'package:ipuc/models/book.dart';
import 'package:ipuc/models/lyric.dart';
import 'package:ipuc/models/paragraph.dart';
import 'package:ipuc/models/presentation.dart';
import 'package:ipuc/models/slide.dart';
import 'package:ipuc/models/song.dart';
import 'package:ipuc/models/testament.dart';
import 'package:ipuc/models/verse.dart';
import 'package:ipuc/models/video_explanation.dart';
import 'package:ipuc/services/bible_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ipuc/services/song_servide.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:video_player_win/video_player_win_plugin.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) WindowsVideoPlayer.registerWith();

  DatabaseHelper databaseHelper =
      DatabaseHelper(); // Crea una instancia de DatabaseHelper
  await databaseHelper.initDb(); // Inicializa la base de datos

  ArgumentController controller = Get.put(ArgumentController());

  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);

    final argument = args[2].isEmpty
        ? const {}
        : jsonDecode(args[2]) as Map<String, dynamic>;

    controller.setArguments(
        WindowController.fromWindowId(windowId), argument, windowId);

    runApp(MySubApp(
      windowController: WindowController.fromWindowId(windowId),
      args: argument,
    ));
  } else {
    await FFMpegHelper.instance.initialize(); // This is a singleton instance

    await Hive.initFlutter();

    Hive.registerAdapter(VerseAdapter());
    Hive.registerAdapter(BookAdapter());
    Hive.registerAdapter(TestamentAdapter());
    Hive.registerAdapter(PresentationAdapter());
    Hive.registerAdapter(SlideAdapter());
    Hive.registerAdapter(SongAdapter());
    Hive.registerAdapter(LyricAdapter());
    Hive.registerAdapter(ParagraphAdapter());
    Hive.registerAdapter(VideoExplanationAdapter());

    /* await Hive.deleteBoxFromDisk('books');
    await Hive.deleteBoxFromDisk('songs');
    await Hive.deleteBoxFromDisk('presentations');
    await Hive.deleteBoxFromDisk('verses');
    await Hive.deleteBoxFromDisk('testaments');
    await Hive.deleteBoxFromDisk('paragraphs');
    await Hive.deleteBoxFromDisk('slides');
    await Hive.deleteBoxFromDisk('lyrics');
    await Hive.deleteBoxFromDisk('videoExplanations');*/

    SongService songService = SongService();
    var songBox = await Hive.openBox('songs');

    // Comprobamos si la caja 'songs' está vacía
    bool shouldShowInitializationView = songBox.isEmpty;
    await songBox.close();

    initializeDateFormatting('es_ES', null).then((_) {
      runApp(MyApp());
    });
  }
}

Future<void> clearAllHiveBoxes() async {
  var boxNames = [
    'presentations',
    'songs',
    'verses',
    'testaments',
    'paragraphs',
    'videoExplanations',
    'videoExplanations',
  ]; // Lista de nombres de boxes
  for (var boxName in boxNames) {
    var box = await Hive.openBox(boxName);
    await box.clear();
  }
}

class MySubApp extends StatelessWidget {
  MySubApp({
    Key? key,
    required this.windowController,
    required this.args,
  }) : super(key: key);

  final WindowController windowController;
  final Map? args;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
          // Aquí puedes especificar varios estilos de texto como headline1, headline2, etc.
          bodyText1: TextStyle(color: Color(0xff7e7e7e)),
          bodyText2: TextStyle(color: Color(0xff7e7e7e)),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Cambia el color de los íconos aquí
        ),
      ),
      title: 'Mi Aplicación',
      initialRoute: AppRoutes.PREVIEW,
      getPages: AppPages.pages,
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
          // Aquí puedes especificar varios estilos de texto como headline1, headline2, etc.
          bodyText1: TextStyle(color: Color(0xff7e7e7e)),
          bodyText2: TextStyle(color: Color(0xff7e7e7e)),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Cambia el color de los íconos aquí
        ),
      ),
      title: 'Mi Aplicación',
      initialRoute: AppRoutes.LOADING,
      getPages: AppPages.pages,
    );
  }
}
