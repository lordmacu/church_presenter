import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/song_controller.dart';
import 'package:localization/localization.dart';

class EditSong extends StatelessWidget {
  EditSong({Key? key}) : super(key: key);
  final SongController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                style: TextStyle(color: Colors.white),
                controller: TextEditingController(
                    text: controller.currentSong.value.title),
                onChanged: (value) =>
                    controller.currentSong.value.title = value,
                decoration: InputDecoration(
                  labelText: 'song_title'.i18n(),
                  labelStyle: TextStyle(
                      color: Colors.grey), // Setting the hint text color
                  // Setting the background color to white
                  filled: true,
                ),
              ),
              Obx(() {
                return Column(
                  children: List.generate(
                    controller.currentSong.value.paragraphs.length,
                    (index) => Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 20, left: 5),
                          child: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('confirm_delete_song'.i18n()),
                                  content: Text('question_delete_song'.i18n()),
                                  actions: [
                                    TextButton(
                                      child: Text('cancel'.i18n()),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('delete'.i18n()),
                                      onPressed: () async {
                                        controller.currentSong.value.paragraphs
                                            .removeAt(index);
                                        Navigator.of(context).pop();

                                        await Future.delayed(
                                            const Duration(milliseconds: 50));

                                        controller.currentSong.refresh();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(
                                text: controller
                                    .currentSong.value.paragraphs[index]),
                            onChanged: (value) => controller
                                .currentSong.value.paragraphs[index] = value,
                            maxLines: null,
                            style: TextStyle(
                                color: Colors
                                    .white), // Setting the text color to black
                            decoration: InputDecoration(
                              labelText:
                                  "paragraph_number".i18n(["${index + 1}"]),
                              labelStyle: TextStyle(
                                  color: Colors
                                      .grey), // Setting the hint text color
                              // Setting the background color to white
                              filled: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  controller.currentSong.value.paragraphs.add("");
                  controller.currentSong.refresh();
                },
                child: Text('add_paragraph'.i18n()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
