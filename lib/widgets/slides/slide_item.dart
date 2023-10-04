import 'package:flutter/material.dart';

class SlideItem extends StatelessWidget {
  final String title;
  final int slideCount;
  final bool isSelected;
  final Function onTap;

  SlideItem({
    required this.title,
    required this.slideCount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: EdgeInsets.all(2),
        margin: EdgeInsets.all(20),
        height: 90,
        decoration: BoxDecoration(
          border: Border.all(
              color: isSelected
                  ? Colors.blue.withOpacity(0.7)
                  : Colors.transparent,
              width: 2),
          borderRadius: BorderRadius.circular(10), // Radio del borde redondeado
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3), // Color de la sombra
              spreadRadius: isSelected ? 10 : 0, // Extensión de la sombra
              blurRadius: isSelected ? 10 : 5, // Desenfoque de la sombra
              offset: Offset(0, 4), // Posición de la sombra
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                "lib/assets/images/paisaje.png",
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10)),
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                ),
                child: Text(
                  "10",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
