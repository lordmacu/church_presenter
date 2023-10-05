import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:ipuc/services/bible_service.dart';
import 'package:ipuc/services/song_servide.dart';
import 'package:localization/localization.dart';

class LoadingView extends StatefulWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  _LoadingView createState() => _LoadingView();
}

class _LoadingView extends State<LoadingView> {
  int _isLoading = 0;

  Future<void> initData() async {
    setState(() {
      _isLoading = 2;
    });

    BibleService versiculoService = BibleService();

    bool hasVersesData = await versiculoService.hasVersesData();
    if (hasVersesData) {
      Get.toNamed('/');
    } else {
      await versiculoService.initVerses();

      SongService songService = SongService();
      await songService.initSongs();

      setState(() {
        _isLoading = 3;
      });
      Get.toNamed('/');
    }
  }

  Future delete() async {
    await Hive.deleteBoxFromDisk('books');
    await Hive.deleteBoxFromDisk('songs');
    await Hive.deleteBoxFromDisk('presentations');
    await Hive.deleteBoxFromDisk('verses');
    await Hive.deleteBoxFromDisk('testaments');
    await Hive.deleteBoxFromDisk('paragraphs');
    await Hive.deleteBoxFromDisk('slides');
    await Hive.deleteBoxFromDisk('lyrics');
    await Hive.deleteBoxFromDisk('videoExplanations');
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _isLoading > 0
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _isLoading == 2
                      ? Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 20),
                            Text('loading_text'.i18n())
                          ],
                        )
                      : Container(),
                ],
              ))
            : Container());
  }
}
