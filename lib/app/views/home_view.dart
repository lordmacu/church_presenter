import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/biblies_controller.dart';
import 'package:ipuc/app/controllers/description_chapter_controller.dart';
import 'package:ipuc/app/controllers/home_controller.dart';
import 'package:ipuc/app/controllers/media_data_controller.dart';
import 'package:ipuc/app/controllers/present_controller.dart';
import 'package:ipuc/app/controllers/preview_controller.dart';
import 'package:ipuc/app/controllers/slide_controller.dart';
import 'package:ipuc/app/controllers/song_controller.dart';
import 'package:ipuc/widgets/media_data/media_data.dart';
import 'package:ipuc/widgets/presents/list_present.dart';
import 'package:ipuc/widgets/slides/slide_presenter.dart';

/// Represents the Home View of the application.

class HomeView extends StatelessWidget {
  HomeView({Key? key}) : super(key: key);
  final SliderController controller = Get.put(SliderController());

  final DescriptionChapterController descriptionController =
      Get.put(DescriptionChapterController());
  final PresentController controllerPresent = Get.put(PresentController());

  final BibliesController bibliesController = Get.put(BibliesController());
  final PreviewController previewController = Get.put(PreviewController());
  final SongController controllerSongs = Get.put(SongController());
  final MediaDataController controllerMedia = Get.put(MediaDataController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (homeController) {
        return Scaffold(
          body: Container(
            color: const Color(0xff353535),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 10,
                  child: Row(
                    children: [
                      _buildLeftPanel(),
                      _buildRightPanel(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the left panel of the Home View.
  ///
  /// The left panel contains the ListPresent and MediaDataWidget.
  Widget _buildLeftPanel() {
    return Expanded(
      flex: 2,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: const Color(0xff2d2d2d).withOpacity(0.9),
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: ListPresent(),
            ),
            Expanded(
              flex: 3,
              child: MediaDataWidget(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the right panel of the Home View.
  ///
  /// The right panel contains the SlidePresenter.
  Widget _buildRightPanel() {
    return Expanded(
      flex: 7,
      child: SlidePresenter(),
    );
  }
}
