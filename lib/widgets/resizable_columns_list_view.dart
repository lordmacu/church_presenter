import 'package:flutter/material.dart';
import 'package:ipuc/app/controllers/column_controller.dart';
import 'package:get/get.dart';

class ResizableColumnsListView extends StatelessWidget {
  final ColumnController columnController = Get.put(ColumnController());

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Row(
          children: [
            buildResizableColumn("column1Width", 'Column 1 - Item $index'),
            buildResizableColumn("column2Width", 'Column 2 - Item $index'),
            buildResizableColumn("column3Width", 'Column 3 - Item $index'),
          ],
        );
      },
    );
  }

  Widget buildResizableColumn(String columnWidthKey, String text) {
    var width = 0.0.obs;
    if (columnWidthKey == "column1Width") {
      width = columnController.column1Width;
    } else if (columnWidthKey == "column2Width") {
      width = columnController.column2Width;
    } else if (columnWidthKey == "column3Width") {
      width = columnController.column3Width;
    }

    return Obx(
      () => GestureDetector(
        onHorizontalDragUpdate: (details) {
          width.value += details.delta.dx;
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeLeftRight,
          child: Container(
            width: width.value,
            child: Text(text),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}
