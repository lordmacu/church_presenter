import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/description_chapter_controller.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';

class DescriptionChapter extends StatelessWidget {
  DescriptionChapter({Key? key}) : super(key: key);
  final DescriptionChapterController controller = Get.find();
  final ScrollController scrollController = ScrollController();
  final ScrollController scrollaController = ScrollController();
  final FocusNode focusNode = FocusNode();

  String cleanRtfText(String text) {
    return text.replaceAllMapped(RegExp(r"\\'([0-9a-f]{2})"), (Match match) {
      return String.fromCharCode(int.parse(match.group(1)!, radix: 16));
    }).replaceAll(RegExp(r"\\[a-z]+"), "");
  }

  sendToViewer(index) async {}

  String getBibleTitle(String bibleName) {
    if (bibleName == "bad") {
      return "Biblia al día";
    }

    if (bibleName == "BLSee") {
      return "Biblia lenguaje sencillo";
    }
    if (bibleName == "NTVivi") {
      return "Nueva traducción viviente";
    }
    if (bibleName == "NVI1999") {
      return "Nueva versión internacional";
    }
    if (bibleName == "PDT8") {
      return "Biblia para todos";
    }
    if (bibleName == "RVC") {
      return "Reina Valera Contemporanea";
    }
    if (bibleName == "RVG10") {
      return "Reina valera Gómez";
    }
    if (bibleName == "rvr1960") {
      return "Reina valera 1960";
    }
    return "Reina valera 1960";
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        onKey: (event) async {
          double itemHeight = 50.0;
          double listViewHeight = 200.0;

          if (event.runtimeType == RawKeyDownEvent &&
              event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
            if (controller.selectedIndex.value <
                controller.versesWithRelations.length - 1) {
              controller.selectedIndex.value++;
              double scrollTo = (controller.selectedIndex.value * itemHeight) -
                  (listViewHeight / 2) +
                  (itemHeight / 2);
              scrollController.jumpTo(scrollTo);
            }
          } else if (event.runtimeType == RawKeyDownEvent &&
              event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
            if (controller.selectedIndex.value > 0) {
              controller.selectedIndex.value--;
              double scrollTo = (controller.selectedIndex.value * itemHeight) -
                  (listViewHeight / 2) +
                  (itemHeight / 2);
              scrollController.jumpTo(scrollTo);
            }
          }
          sendToViewer(controller.selectedIndex.value);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Center(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...List.generate(controller.versions.value.length, (index) {
                      return Tooltip(
                        message:
                            getBibleTitle(controller.versions.value[index]),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Obx(() => ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          controller.selectedVersion.value ==
                                                  controller
                                                      .versions.value[index]
                                              ? Colors.blue
                                              : Colors.grey),
                                ),
                                onPressed: () async {
                                  controller.selectedVersion.value =
                                      controller.versions.value[index];
                                  controller.loadBibleByVersion();
                                  if (controller.searchQuery.value.isNotEmpty) {
                                    controller.updateSearch(
                                        controller.searchQuery.value);
                                  }
                                },
                                child: Text(
                                  controller.versions.value[index],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              )),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: TextField(
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
                onChanged: (text) => controller.updateSearch(text),
                decoration: InputDecoration(
                  labelText: 'search_verses'.i18n(),
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  hintText: 'write_to_search'.i18n(),
                  hintStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF3c3b3c),
                    Color(0xFF393839),
                    Color(0xFF333333),
                  ],
                ),
                border: Border(
                  top: BorderSide(
                    color: Color(0xFF2d2d2d),
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: Color(0xFF2d2d2d),
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const SizedBox(
                    child: Text(' '),
                    width: 100,
                  ),
                  Text('verse'.i18n()),
                ],
              ),
            ),
            Expanded(
              child: Scrollbar(
                  controller: scrollaController,
                  child: Obx(
                    () => ListView.builder(
                      controller: scrollaController,
                      itemCount: controller.versesWithRelations.length,
                      itemBuilder: (context, index) {
                        final verse = controller.versesWithRelations[index];

                        return Obx(() => GestureDetector(
                              onTap: () async {
                                controller.selectedIndex.value = index;

                                sendToViewer(controller.selectedIndex.value);
                              },
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        child: Row(
                                          children: [
                                            IconButton(
                                              tooltip: "add".i18n(),
                                              icon: const Icon(Icons.add),
                                              onPressed: () {
                                                controller.addNewVerse(
                                                    verse['verse'],
                                                    verse['text'],
                                                    verse['book_text'],
                                                    verse['chapter']);
                                              },
                                            ),
                                            IconButton(
                                              tooltip: "present".i18n(),
                                              icon: const Icon(
                                                  Icons.present_to_all),
                                              onPressed: () {
                                                controller
                                                    .sendDirectToPresentation(
                                                        verse['verse'],
                                                        verse['text'],
                                                        verse['book_text'],
                                                        verse['chapter']);
                                              },
                                            ),
                                          ],
                                        ),
                                        width: 100,
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              '${verse['text'].trim()}',
                                              softWrap: true,
                                              overflow: TextOverflow.clip,
                                              maxLines: 3,
                                              style: TextStyle(
                                                color: controller.selectedIndex
                                                            .value ==
                                                        index
                                                    ? const Color(0xffa0a0a0)
                                                    : const Color(0xffa0a0a0),
                                              ),
                                            ),
                                            Text(
                                              '${verse['book_text']} ${verse['chapter']}:${verse['verse']} (${verse['version']})',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: const Color(0xff979797)
                                          .withOpacity(0.3),
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
                  )),
            ),
          ],
        ));
  }
}
