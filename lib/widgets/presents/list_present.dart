import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/present_controller.dart';
import 'package:ipuc/widgets/title_bar.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ListPresent extends StatelessWidget {
  final PresentController controller = Get.find();
  final ScrollController scrollController = ScrollController();
  final BoxController boxController = BoxController();
  final GlobalKey myWidgetKey = GlobalKey();
  final TextEditingController controllerTopic = TextEditingController();
  final TextEditingController controllerPreacher = TextEditingController();
  late BuildContext _context;

  void resetForm() {
    final RenderBox renderBox =
        myWidgetKey.currentContext!.findRenderObject() as RenderBox;
    controller.resetValues(renderBox.size.height);
    controllerPreacher.text = "";
    controllerTopic.text = "";
    boxController.openBox();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      floatingActionButton: Obx(() {
        return AnimatedOpacity(
          opacity: !controller.isPanelOpen.value ? 1.0 : 0.0,
          duration: Duration(milliseconds: 100), // Duración del efecto
          child: FloatingActionButton(
            heroTag: "five",
            onPressed: () {
              controller.addEmptyPresentation();
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.blue,
          ),
        );
      }),
      body: Obx(() => buildBody(context)),
    );
  }

  Widget buildBody(BuildContext context) {
    return Container(
      child: SlidingBox(
        draggable: false,
        collapsed: true,
        controller: boxController,
        minHeight: 0,
        onBoxOpen: () {
          controller.isPanelOpen.value = true;
        },
        onBoxClose: () {
          controller.isPanelOpen.value = false;
        },
        maxHeight: controller.heightItem.value - 100,
        backdrop: buildBackdrop(),
        body: buildForm(),
      ),
    );
  }

  Backdrop buildBackdrop() {
    return Backdrop(
      overlay: true,
      moving: false,
      body: Container(
        key: myWidgetKey,
        color: Color(0xff353535),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            TitleBar(title: "Presentaciones"),
            Expanded(
              child: Scrollbar(
                controller: scrollController,
                child: buildListView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListView buildListView() {
    return ListView.builder(
      controller: scrollController,
      itemCount: controller.presentations.value.length,
      itemBuilder: (context, index) {
        return buildListItem(index);
      },
    );
  }

  Obx buildListItem(int index) {
    return Obx(() {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        color:
            controller.selectedItem.value == controller.presentations[index].key
                ? Color(0xFF6c6c6c)
                : Colors.transparent,
        child: buildListTile(index),
      );
    });
  }

  ListTile buildListTile(int index) {
    final imagePath = controller.presentations[index].image;
    final topic = controller.presentations[index].topic;
    return ListTile(
      onTap: () {
        controller.selectItem(controller.presentations[index].key);
      },
      title: Text(
        topic,
        style: TextStyle(color: Colors.white),
      ),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.white),
          onPressed: () {
            final RenderBox renderBox =
                myWidgetKey.currentContext!.findRenderObject() as RenderBox;
            controller.resetValues(renderBox.size.height);
            controller.isPanelOpen.value = true;

            // Acciones de edición aquí, como abrir una nueva ventana o un modal para editar
            controller.doubleTapItem(
                index,
                renderBox.size
                    .height); // Por ejemplo, puedes reutilizar tu función doubleTapItem

            controllerPreacher.text = controller.presentations[index].preacher;
            controllerTopic.text = controller.presentations[index].topic;
            boxController.openBox();
          },
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.white),
          onPressed: () async {
            // Mostrar un cuadro de diálogo de confirmación
            final bool? result = await showDialog<bool>(
              context: _context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Confirmación"),
                  content: Text(
                      "¿Estás seguro de que quieres borrar la presentación? Esto también eliminará todos los slides dentro."),
                  actions: <Widget>[
                    TextButton(
                      child: Text("Cancelar"),
                      onPressed: () {
                        Navigator.of(context).pop(
                            false); // Devuelve 'false' si el usuario pulsa 'Cancelar'
                      },
                    ),
                    TextButton(
                      child: Text("Aceptar"),
                      onPressed: () {
                        Navigator.of(context).pop(
                            true); // Devuelve 'true' si el usuario pulsa 'Aceptar'
                      },
                    ),
                  ],
                );
              },
            );

            // Si el usuario confirmó la acción
            if (result == true) {
              controller.key.value = controller.presentations[index].key;
              controller.deletePresentation();
            }
          },
        )
      ]),
    );
  }

  Container buildForm() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Form(
        child: Column(
          children: [
            buildDateText(),
            buildTextField(
              controller: controllerTopic,
              label: 'Tema',
              onChanged: (value) => controller.topic.value = value,
            ),
            buildTextField(
              controller: controllerPreacher,
              label: 'Predicador',
              onChanged: (value) => controller.preacher.value = value,
            ),
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 20),
              child: buildImageSection(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [buildSaveButton()],
            )
          ],
        ),
      ),
    );
  }

  ElevatedButton buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        controller.savePresentation();
        boxController.closeBox();
      },
      child: Text('Guardar'),
    );
  }

  Obx buildImageSection() {
    RxBool showHint =
        false.obs; // Observable para controlar la visibilidad del hint

    return Obx(() {
      return controller.image.value.isEmpty
          ? ElevatedButton(
              onPressed: controller.pickImage,
              child: Text('Seleccionar imagen'),
            )
          : MouseRegion(
              onEnter: (_) => showHint.value = true,
              onExit: (_) => showHint.value = false,
              cursor: SystemMouseCursors.click,
              child: Obx(
                () => Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        controller.pickImage();
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.file(
                          File(controller.image.value),
                          width: 200,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (showHint.value)
                      Icon(
                        Icons.edit, // Este es solo un icono de ejemplo
                        color: Colors.blue,
                      ),
                  ],
                ),
              ),
            );
    });
  }

  TextFormField buildTextField({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }

  Obx buildDateText() {
    return Obx(() {
      final DateTime date = controller.date.value;
      final String formattedDate =
          DateFormat("d 'de' MMMM", 'es_ES').format(date);
      return Text("Predicación del $formattedDate");
    });
  }
}
