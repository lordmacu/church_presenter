import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:ipuc/app/controllers/song_controller.dart';
import 'package:ipuc/models/songdb.dart';
import 'package:flutter/services.dart';
import 'package:ipuc/widgets/song/edit_song.dart';
import 'package:localization/localization.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class SongsList extends StatelessWidget {
  SongsList({Key? key}) : super(key: key);
  final SongController controller = Get.find();
  final ScrollController scrollController = ScrollController();
  final ScrollController scrollaController = ScrollController();
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: TextField(
                    onChanged: (text) => controller.searchSongs(text),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'search_songs'.i18n(),
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      hintText: 'write_to_search_songs'.i18n(),
                      hintStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
              SizedBox(
                child: Text('lyric'.i18n()),
                width: 100,
              ),
            ],
          ),
        ),
        Expanded(
          child: Scrollbar(
              controller: scrollaController,
              child: Obx(
                () => ListView.builder(
                  controller: scrollaController,
                  itemCount: controller.songsdb.length,
                  itemBuilder: (context, index) {
                    SongDb song = controller.songsdb[index];

                    return Obx(() => GestureDetector(
                          onTap: () async {
                            controller.selectedIndex.value = index;
                          },
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    child: Row(
                                      children: [
                                        IconButton(
                                          tooltip: "add_to_presentation".i18n(),
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            controller
                                                .addNewSongToPresenter(song);
                                          },
                                        ),
                                        IconButton(
                                          tooltip: "edit_song".i18n(),
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            controller.currentSong.value = song;

                                            WoltModalSheet.show<void>(
                                              context: context,
                                              enableDrag: true,
                                              barrierDismissible: true,
                                              pageListBuilder:
                                                  (modalSheetContext) {
                                                final textTheme =
                                                    Theme.of(context).textTheme;
                                                return [
                                                  editSongPage(
                                                      modalSheetContext,
                                                      textTheme),
                                                ];
                                              },
                                              modalTypeBuilder: (context) {
                                                return WoltModalType.dialog;
                                              },
                                              onModalDismissedWithBarrierTap:
                                                  () {},
                                              maxDialogWidth: 1000,
                                              minDialogWidth: 1000,
                                              minPageHeight: 0.0,
                                              maxPageHeight: 0.9,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    width: 90,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          song.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        song.paragraphs.isNotEmpty
                                            ? Text(
                                                '${song.paragraphs[0].length > 60 ? song.paragraphs[0].substring(0, 60) + "..." : song.paragraphs[0]}',
                                                style: TextStyle(
                                                  color: controller
                                                              .selectedIndex
                                                              .value ==
                                                          index
                                                      ? const Color(0xffa0a0a0)
                                                      : const Color(0xffa0a0a0),
                                                ),
                                              )
                                            : Text(
                                                'no_lyrics_available'.i18n(),
                                                style: const TextStyle(
                                                  color: Color(0xffa0a0a0),
                                                ),
                                              ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color:
                                      const Color(0xff979797).withOpacity(0.3),
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

  WoltModalSheetPage editSongPage(
      BuildContext modalSheetContext, TextTheme textTheme) {
    return WoltModalSheetPage.withSingleChild(
      hasSabGradient: false,
      backgroundColor: Color(0xff353535),
      trailingNavBarWidget: Container(
        padding: EdgeInsets.only(right: 10),
        child: IconButton(
          onPressed: () {
            Navigator.of(modalSheetContext).pop();
          },
          icon: Icon(
            Icons.close,
            color: Colors.grey,
          ),
        ),
      ),
      topBarTitle: Obx(() => Text(
          controller.currentSong.value.id == ""
              ? 'add_song'.i18n()
              : 'edit_song'.i18n(),
          style: TextStyle(color: Colors.white))),
      isTopBarLayerAlwaysVisible: true,
      child: SizedBox(
        height: 500,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: EditSong(),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(modalSheetContext).pop();
                if (controller.currentSong.value.id == "") {
                  await controller.addNewDbSong();
                } else {
                  await controller.updateDbSong();
                }
              },
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: Center(child: Text('save'.i18n())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
