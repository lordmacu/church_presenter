import 'package:flutter/material.dart';
import 'package:ipuc/widgets/live_output/play.dart';
import 'package:ipuc/widgets/title_bar.dart';

class LiveWidget extends StatelessWidget {
  const LiveWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TitleBar(title: "En vivo"),
        Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: PlayWidget(),
              )
            ],
          ),
        )
      ],
    );
  }
}
