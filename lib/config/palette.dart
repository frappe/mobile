import 'package:flutter/material.dart';

// Color palette for the unthemed pages
class Palette {
  static Color offWhite = Color.fromRGBO(250, 251, 252, 1);
  static Color lightGrey = Color.fromRGBO(209, 216, 221, 1);
  static Color darkGrey = Color.fromRGBO(141, 153, 166, 1);
  static Color lightGreen = Color.fromRGBO(238, 247, 241, 1);
  static Color darkGreen = Color.fromRGBO(56, 161, 96, 1);
  static Color bgColor = Color.fromRGBO(237, 242, 247, 1);
  static Color dimTxtColor = Color.fromRGBO(185, 192, 199, 1);
  static Color fieldBgColor = Color.fromRGBO(244, 245, 246, 1);
  // TODO: move
  static TextStyle labelStyle = TextStyle(
    color: Color.fromRGBO(174, 186, 202, 1),
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  static TextStyle dimTxtStyle = TextStyle(
    color: Palette.dimTxtColor,
    fontWeight: FontWeight.bold,
  );
}
