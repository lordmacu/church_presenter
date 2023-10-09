import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:ipuc/services/bible_service.dart';
import 'package:ipuc/services/song_servide.dart';
import 'package:localization/localization.dart';

/// Represents the Loading View screen of the application.
class LoadingView extends StatefulWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  _LoadingView createState() => _LoadingView();
}

class _LoadingView extends State<LoadingView> {
  int _isLoading = 0;

  /// Initialize data needed for the app to run.
  Future<void> initData() async {
    setState(() {
      _isLoading = 2;
    });

    final BibleService bibleService = BibleService();
    final bool hasVersesData = await bibleService.hasVersesData();

    if (hasVersesData) {
      Get.toNamed('/');
    } else {
      await _performInitialization(bibleService);
    }
  }

  /// Perform the data initialization steps.
  Future<void> _performInitialization(BibleService bibleService) async {
    await bibleService.initVerses();

    final SongService songService = SongService();
    await songService.initSongs();

    setState(() {
      _isLoading = 3;
    });
    Get.toNamed('/');
  }

  /// Delete all Hive boxes from disk.
  Future<void> deleteAllHiveBoxes() async {
    final boxNames = [
      'books',
      'songs',
      'presentations',
      'verses',
      'testaments',
      'paragraphs',
      'slides',
      'lyrics',
      'videoExplanations',
    ];
    for (var box in boxNames) {
      await Hive.deleteBoxFromDisk(box);
    }
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
              child: _buildLoadingIndicator(),
            )
          : Container(),
    );
  }

  /// Builds the loading indicator widget.
  Widget _buildLoadingIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _isLoading == 2
            ? Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text('loading_text'.i18n()),
                ],
              )
            : Container(),
      ],
    );
  }
}
