import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/biblies_controller.dart';
import 'package:ipuc/widgets/title_bar.dart';
import 'package:localization/localization.dart';

class Biblies extends StatelessWidget {
  Biblies({Key? key}) : super(key: key);
  final BibliesController controller = Get.find();
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff282828),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TitleBar(title: 'bibles'.i18n()),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                SizedBox(
                                  child: Text(
                                    ' ',
                                    style: TextStyle(
                                      color: controller.selectedIndex.value ==
                                              index
                                          ? const Color(0xff979797)
                                          : const Color(0xff656565),
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
                                color: const Color(0xff979797).withOpacity(0.3),
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
