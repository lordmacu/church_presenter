import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ipuc/app/controllers/preview_controller.dart';
import 'package:ipuc/widgets/live_output/play.dart';
import 'package:ipuc/widgets/live_output/preview.dart';
import 'package:ipuc/widgets/title_bar.dart';

class LiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleBar(title: "En vivo"),
        Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  child: PlayWidget(),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
