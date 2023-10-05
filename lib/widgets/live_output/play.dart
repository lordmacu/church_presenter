import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/present_controller.dart';
import 'package:ipuc/app/controllers/slide_controller.dart';

class PlayWidget extends StatelessWidget {
  PlayWidget({Key? key}) : super(key: key);
  final SliderController controller = Get.find();
  final PresentController controllerPresenter = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () async {
                await controllerPresenter.sendDataToPresentation(null);
              },
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 20.0,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
