import 'package:flutter/material.dart';

class TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function onTap;

  const TabButton(
      {Key? key,
      required this.title,
      required this.isSelected,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: !isSelected ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: () => {onTap()},
        child: isSelected
            ? Container(
                margin: const EdgeInsets.only(left: 5, right: 5),
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 5),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xffb0b0b0),
                      Color(0xffa0a0a0),
                      Color(0xffa0a0a0),
                    ],
                  ),
                ),
                child: Text(
                  title,
                  style: const TextStyle(color: Color(0xff4c4c4c)),
                ),
              )
            : Container(
                color: Colors.transparent,
                margin: const EdgeInsets.only(left: 5, right: 5),
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 5),
                child: Text(
                  title,
                  style: const TextStyle(color: Color(0xff929292)),
                ),
              ),
      ),
    );
  }
}
