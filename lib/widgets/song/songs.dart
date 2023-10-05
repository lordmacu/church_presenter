import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:ipuc/app/controllers/description_chapter_controller.dart';
import 'package:ipuc/app/controllers/song_list_controller.dart';
import 'package:ipuc/models/book.dart';
import 'package:ipuc/models/song.dart';
import 'package:ipuc/models/songdb.dart';
import 'package:ipuc/models/testament.dart';
import 'package:ipuc/models/verse.dart';
import 'package:flutter/services.dart';

class SongsList extends StatelessWidget {
  final SongListController controller = Get.find();
  ScrollController scrollController = ScrollController();
  ScrollController scrollaController = ScrollController();
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        onKey: (event) async {
          double itemHeight = 50.0; // La altura de cada ítem de la lista.
          double listViewHeight =
              200.0; // La altura del ListView. Actualízala según tu diseño.

          if (event.runtimeType == RawKeyDownEvent &&
              event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
            if (controller.selectedIndex.value < controller.songs.length - 1) {
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
          //sendToViewer(controller.selectedIndex.value);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Campo de texto para buscar canciones
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: TextField(
                        onChanged: (text) => controller.searchSongs(text),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Buscar Canción',
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          hintText: 'Escribe para buscar',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Botón para borrar canciones
                  ElevatedButton(
                    onPressed: () async {
                      Get.toNamed('/loading');
                    },
                    child: const Text(
                      'Borrar Canciones',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
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
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    child: Text(' '),
                    width: 100,
                  ),
                  Container(
                    child: Text('Letra'),
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
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        child: Row(
                                          children: [
                                            IconButton(
                                              tooltip:
                                                  "Agregar a la presentación",
                                              icon: Icon(Icons.add),
                                              onPressed: () {
                                                print(
                                                    "estar aqui ${song.paragraphs[0]}");
                                                controller.addNewSong(song);
                                              },
                                            ),
                                          ],
                                        ),
                                        width: 100,
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Título de la canción
                                              Text(
                                                '${song.title}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(
                                                  height:
                                                      10), // Espaciado entre el título y el párrafo
                                              // Párrafo de la canción
                                              song.paragraphs.isNotEmpty
                                                  ? Text(
                                                      '${song.paragraphs[0].length > 60 ? song.paragraphs[0].substring(0, 60) + "..." : song.paragraphs[0]}',
                                                      style: TextStyle(
                                                        color: controller
                                                                    .selectedIndex
                                                                    .value ==
                                                                index
                                                            ? Color(0xffa0a0a0)
                                                            : Color(0xffa0a0a0),
                                                      ),
                                                    )
                                                  : Text(
                                                      'No lyrics available', // Mostrar este texto si no hay letras o párrafos disponibles
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xffa0a0a0),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      )
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
                  )),
            ),
          ],
        ));
  }
}
