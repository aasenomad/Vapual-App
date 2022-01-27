import 'package:vapual/config/app.dart';
import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final String color;
  const LogoWidget(this.size, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Vapual",
          style: TextStyle(fontWeight: FontWeight.bold, color: color == "dark" ? Colors.white: Colors.black, fontSize: size),
        ),
        Text(
          ".",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: size, color: colorPrimary),
        ),
      ],
    );
  }
}
