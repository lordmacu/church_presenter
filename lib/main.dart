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
import 'package:localization/localization.dart';
import 'package:video_player_win/video_player_win_plugin.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) WindowsVideoPlayer.registerWith();

  DatabaseHelper databaseHelper = DatabaseHelper();
  await databaseHelper.initDb();

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

    await FFMpegHelper.instance.initialize();

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
  ];
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
    LocalJsonLocalization.delegate.directories = ['lib/i18n'];

    return GetMaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        LocalJsonLocalization.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('es', 'ES'),
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xff353535),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xff7e7e7e)),
          bodyMedium: TextStyle(color: Color(0xff7e7e7e)),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      title: 'Ipuc',
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
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    LocalJsonLocalization.delegate.directories = ['lib/i18n'];

    return GetMaterialApp(
      localeResolutionCallback: (locale, supportedLocales) {
        if (supportedLocales.contains(locale)) {
          return locale;
        }

        return Locale('es', 'ES');
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        LocalJsonLocalization.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('es', 'ES'),
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xff353535),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xff7e7e7e)),
          bodyMedium: TextStyle(color: Color(0xff7e7e7e)),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      title: 'Mi Aplicación',
      initialRoute: AppRoutes.loading,
      getPages: AppPages.pages,
    );
  }
}
