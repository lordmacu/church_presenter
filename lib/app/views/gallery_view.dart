import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class GalleryView extends StatelessWidget {
  final String folderName;
  Function selectImage;

  GalleryView({required this.folderName, required this.selectImage});

  Future<List<FileSystemEntity>> getFilesInDirectory() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String docPath = appDocDir.path;
    final directory = Directory('$docPath/$folderName');
    return directory.listSync();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FileSystemEntity>>(
      future: getFilesInDirectory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final files = snapshot.data!;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.0, // Ajusta esto según tus necesidades
          ),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            if (file is File &&
                (file.path.endsWith('.jpg') || file.path.endsWith('.png'))) {
              return InkWell(
                onTap: () {
                  selectImage(file.path);
                },
                hoverColor: Colors.transparent,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Image.file(file),
                    ),
                  ),
                ),
              );
            }
            return Container(); // empty container for non-image files
          },
        );
      },
    );
  }
}
