import 'package:flutter/material.dart';
import 'package:ipuc/app/controllers/media_data_controller.dart';
import 'package:ipuc/widgets/bible/description_chapters.dart';
import 'package:ipuc/widgets/song/songs.dart';
import 'package:ipuc/widgets/tab_button.dart';
import 'package:get/get.dart';

class MediaDataWidget extends StatelessWidget {
  MediaDataWidget({Key? key}) : super(key: key);
  final MediaDataController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          padding:
              const EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 5),
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff707070),
                Color(0xff626262),
                Color(0xff585858),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: Color(0xFF2d2d2d),
                width: 1,
              ),
              bottom: BorderSide(
                color: Color(0xff9c9c9c),
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              Obx(() => TabButton(
                    title: "Canciones",
                    onTap: () {
                      controller.selectedItem.value = 1;
                    },
                    isSelected: controller.selectedItem.value == 1,
                  )),
              Obx(() => TabButton(
                    title: "Biblia",
                    onTap: () {
                      controller.selectedItem.value = 2;
                    },
                    isSelected: controller.selectedItem.value == 2,
                  )),
            ],
          ),
        ),
        Obx(() => controller.selectedItem.value == 2
            ? Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 9,
                      child: DescriptionChapter(),
                    )
                  ],
                ),
              )
            : Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 9,
                      child: SongsList(),
                    )
                  ],
                ),
              ))
      ],
    );
  }
}
