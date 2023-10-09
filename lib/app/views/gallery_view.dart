import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// A stateless widget to display a gallery view of images stored in a specific folder.
class GalleryView extends StatelessWidget {
  /// The name of the folder where the images are stored.
  final String folderName;

  /// A callback function to handle image selection.
  final Function selectImage;

  /// Creates an instance of [GalleryView].
  ///
  /// [folderName] is the name of the folder where the images are stored.
  /// [selectImage] is a callback function to handle image selection.
  const GalleryView({
    Key? key,
    required this.folderName,
    required this.selectImage,
  }) : super(key: key);

  /// Retrieves the list of files in the specified directory.
  ///
  /// Returns a [Future] containing a list of [FileSystemEntity].
  Future<List<FileSystemEntity>> getFilesInDirectory() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String docPath = appDocDir.path;
    final directory = Directory('$docPath/$folderName');

    // Check if the directory exists
    if (!await directory.exists()) {
      return [];
    }
    return directory.listSync();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FileSystemEntity>>(
      future: getFilesInDirectory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final files = snapshot.data ?? [];

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.0,
          ),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];

            if (file is File &&
                (file.path.endsWith('.jpg') || file.path.endsWith('.png'))) {
              return InkWell(
                onTap: () => selectImage(file.path),
                hoverColor: Colors.transparent,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Image.file(file),
                    ),
                  ),
                ),
              );
            }

            return Container();
          },
        );
      },
    );
  }
}
