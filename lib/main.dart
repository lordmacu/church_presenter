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
import 'package:intl/date_symbol_data_local.dart';
import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import 'package:video_player_win/video_player_win_plugin.dart';
import 'package:window_manager/window_manager.dart';

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
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

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

    var songBox = await Hive.openBox('songs');

    await songBox.close();

    initializeDateFormatting('es_ES', null).then((_) {
      runApp(const MyApp());
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
  const MySubApp({
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
        scaffoldBackgroundColor: Colors
            .black, // Esto hace que todos los Scaffold tengan un fondo negro

        textTheme: const TextTheme(
          // Aquí puedes especificar varios estilos de texto como headline1, headline2, etc.
          bodyLarge: TextStyle(color: Color(0xff7e7e7e)),
          bodyMedium: TextStyle(color: Color(0xff7e7e7e)),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Cambia el color de los íconos aquí
        ),
      ),
      title: 'Mi Aplicación',
      initialRoute: AppRoutes.preview,
      getPages: AppPages.pages,
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _init();
  }

  @override
  void onWindowClose() async {
    bool _isPreventClose = await windowManager.isPreventClose();
    if (_isPreventClose) {
      try {
        var subWindowIds = await DesktopMultiWindow.getAllSubWindowIds();

        await WindowController.fromWindowId(subWindowIds[0]).close();
      } catch (e) {
        //catch exception
      }

      await windowManager.destroy();
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  void _init() async {
    // Add this line to override the default close handler
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors
            .black, // Esto hace que todos los Scaffold tengan un fondo negro
        textTheme: const TextTheme(
          // Aquí puedes especificar varios estilos de texto como headline1, headline2, etc.
          bodyLarge: TextStyle(
              color: Color(0xff7e7e7e)), // This was previously bodyText1
          bodyMedium: TextStyle(color: Color(0xff7e7e7e)),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Cambia el color de los íconos aquí
        ),
      ),
      title: 'Mi Aplicación',
      initialRoute: AppRoutes.loading, // Reemplaza con tu ruta inicial
      getPages: AppPages.pages, // Reemplaza con tus páginas
    );
  }
}
