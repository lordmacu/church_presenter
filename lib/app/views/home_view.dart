import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/biblies_controller.dart';
import 'package:ipuc/app/controllers/description_chapter_controller.dart';
import 'package:ipuc/app/controllers/home_controller.dart';
import 'package:ipuc/app/controllers/media_data_controller.dart';
import 'package:ipuc/app/controllers/present_controller.dart';
import 'package:ipuc/app/controllers/preview_controller.dart';
import 'package:ipuc/app/controllers/slide_controller.dart';
import 'package:ipuc/app/controllers/song_list_controller.dart';
import 'package:ipuc/widgets/media_data/media_data.dart';
import 'package:ipuc/widgets/presents/list_present.dart';
import 'package:ipuc/widgets/slides/slide_presenter.dart';

class HomeView extends StatelessWidget {
  HomeView({Key? key}) : super(key: key);
  final SliderController controller = Get.put(SliderController());
  final MediaDataController mediaDataController =
      Get.put(MediaDataController());
  final DescriptionChapterController descriptionController =
      Get.put(DescriptionChapterController());
  final PresentController controllerPresent = Get.put(PresentController());

  final BibliesController bibliesController = Get.put(BibliesController());
  final PreviewController previewController = Get.put(PreviewController());
  final SongListController controllerSongs = Get.put(SongListController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
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
                    Expanded(
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
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: SlidePresenter(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
      },
    );
  }
}
