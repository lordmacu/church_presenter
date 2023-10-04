import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/biblies_controller.dart';
import 'package:ipuc/app/controllers/description_chapter_controller.dart';
import 'package:ipuc/app/controllers/slide_controller.dart';
import 'package:ipuc/widgets/title_bar.dart';

class Biblies extends StatelessWidget {
  final BibliesController controller = Get.find();
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff282828),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TitleBar(title: "Biblias"),
          Expanded(
            child: Scrollbar(
              controller: scrollController,
              child: ListView.builder(
                controller: scrollController,
                itemCount: 20,
                itemBuilder: (context, index) {
                  return Obx(() => GestureDetector(
                        onTap: () {
                          controller.selectedIndex.value = index;
                        },
                        child: Container(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  child: Text(
                                    'RV60',
                                    style: TextStyle(
                                      color: controller.selectedIndex.value ==
                                              index
                                          ? Color(0xff979797)
                                          : Color(0xff656565),
                                    ),
                                  ),
                                  width: 100,
                                ),
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xff979797).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            color: controller.selectedIndex.value == index
                                ? Colors.grey[600]
                                : Colors.transparent,
                          ),
                        ),
                      ));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
