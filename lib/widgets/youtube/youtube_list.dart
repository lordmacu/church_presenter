import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/slide_controller.dart';
import 'package:ipuc/app/controllers/youtube_controller.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class YoutubeList extends StatelessWidget {
  final Function selectImage;

  YoutubeList({Key? key, required this.selectImage}) : super(key: key);
  YoutubeController controller = Get.put(YoutubeController());
  final SliderController controllerSlide = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Obx(() => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: controller.searches.length,
                  itemBuilder: (context, index) {
                    var search = controller.searches.value[index];
                    return InkWell(
                      onTap: () async {
                        EasyLoading.show(
                            status: 'Descargando video...',
                            maskType: EasyLoadingMaskType.black);
                        String videoPath = await controller
                            .downloadVideo(search['videoId'].toString());

                        Uuid uuid = const Uuid();

                        final directory =
                            await getApplicationDocumentsDirectory();
                        final String randomThumbnailName = uuid.v1();
                        final thumbnailPath = path.join(
                            directory.path, '$randomThumbnailName.png');
                        const seconds = '0:00:01.000000';

                        await controllerSlide.createThumbnailFile(
                            videoPath, thumbnailPath, seconds);

                        selectImage(thumbnailPath, videoPath);

                        EasyLoading.dismiss();
                      },
                      hoverColor: Colors.transparent,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Expanded(
                                // Asegura que la imagen ocupa todo el espacio vertical disponible
                                child: AspectRatio(
                                  aspectRatio:
                                      1, // Para mantener la relación de aspecto
                                  child: Image.network(
                                    search['thumbnail'],
                                    fit: BoxFit.cover,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.black,
                                        child: Center(
                                          child: Text(
                                            search['title'].length > 20
                                                ? search['title']
                                                        .substring(0, 20) +
                                                    '...'
                                                : search['title'],
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ); // Retorna un contenedor vacío si hay un error
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height:
                                      5), // Espacio entre la imagen y el texto
                              Text(
                                "${search['title'].length > 20 ? search['title'].substring(0, 20) + '...' : search['title']}",
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )),
          ),
          Obx(() => controller.nextPage.value != ""
              ? Padding(
                  padding: EdgeInsets.all(10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () async {
                      EasyLoading.show(
                          status: 'Cargando videos...',
                          maskType: EasyLoadingMaskType.black);

                      await controller.getNextYoutubeVideos();
                      EasyLoading.dismiss();
                    },
                    child: Text('Cargar más'),
                  ),
                )
              : Container()),
        ],
      ),
    );
  }
}
