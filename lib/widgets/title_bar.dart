import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget {
  final String title;

  TitleBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 3, top: 3),
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
      child: Text(this.title, style: TextStyle(fontSize: 13)),
    );
  }
}
