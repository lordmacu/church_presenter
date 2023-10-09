import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/biblies_controller.dart';
import 'package:ipuc/widgets/title_bar.dart';
import 'package:localization/localization.dart';

/// The Biblies class is a stateless widget that displays a list of bibles.
///
/// It uses GetX for state management and listens for changes to display the correct data.
class Biblies extends StatelessWidget {
  /// Default constructor, which accepts an optional key.
  Biblies({Key? key}) : super(key: key);

  /// Instance of BibliesController fetched using GetX.
  final BibliesController controller = Get.find();

  /// Scroll controller for the ListView.
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff282828),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title Bar displaying 'bibles'
          TitleBar(title: 'bibles'.i18n()),
          Expanded(
            child: Scrollbar(
              controller: scrollController,
              child: ListView.builder(
                controller: scrollController,
                itemCount: 20, // Dummy item count, replace with actual count
                itemBuilder: (context, index) {
                  return Obx(() {
                    // A GestureDetector widget to handle taps.
                    return GestureDetector(
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
                                  ' ', // Empty placeholder, replace as needed
                                  style: TextStyle(
                                    color:
                                        controller.selectedIndex.value == index
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
                    );
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
