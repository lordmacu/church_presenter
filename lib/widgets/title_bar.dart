import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget {
  final String title;

  const TitleBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 3, top: 3),
      width: double.infinity,
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
      child: Text(title, style: const TextStyle(fontSize: 13)),
    );
  }
}
