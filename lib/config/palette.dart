import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_palette.dart';

// Color palette for the unthemed pages
class Palette {
  static Color bgColor = FrappePalette.grey[200];
  static Color fieldBgColor = FrappePalette.grey[100];
  static Color iconColor = FrappePalette.grey[700];
  static Color primaryButtonColor = FrappePalette.blue;
  static Color secondaryButtonColor = FrappePalette.grey[200];
  static Color disabledButonColor = FrappePalette.grey;

  static Color dangerTxtColor = FrappePalette.red[600];
  static Color dangerBgColor = FrappePalette.red[100];
  static Color warningTxtColor = FrappePalette.orange[600];
  static Color warningBgColor = FrappePalette.orange[100];
  static Color completeTxtColor = FrappePalette.blue[600];
  static Color completeBgColor = FrappePalette.blue[100];
  static Color undefinedTxtColor = FrappePalette.grey[600];
  static Color undefinedBgColor = FrappePalette.grey[100];
  static Color successTxtColor = FrappePalette.darkGreen[600];
  static Color successBgColor = FrappePalette.darkGreen[100];

  static Color secondaryTxtColor = Color.fromRGBO(185, 192, 199, 1);
  static Color newIndicatorColor = Color.fromRGBO(255, 252, 231, 1);
  // TODO: move

  static TextStyle secondaryTxtStyle = TextStyle(
    color: Palette.secondaryTxtColor,
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  static TextStyle altTextStyle = TextStyle(
    fontStyle: FontStyle.italic,
    color: Palette.secondaryTxtColor,
  );

  static InputDecoration formFieldDecoration(bool withLabel, String label) {
    return InputDecoration(
      hintText: !withLabel ? label : null,
      enabledBorder: InputBorder.none,
      filled: true,
      fillColor: Palette.fieldBgColor,
    );
  }
}
