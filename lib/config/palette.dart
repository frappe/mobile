import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_palette.dart';

// Color palette for the unthemed pages
class Palette {
  static Color bgColor = FrappePalette.grey[100];
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

  static Color secondaryTxtColor = Color(0xFFB9C0C7);
  static Color newIndicatorColor = Color.fromRGBO(255, 252, 231, 1);

  static EdgeInsets fieldPadding = const EdgeInsets.only(bottom: 24.0);
  static EdgeInsets labelPadding = const EdgeInsets.only(bottom: 6.0);

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

  // TODO
  static InputDecoration formFieldDecoration({
    @required bool withLabel,
    @required String label,
    Widget suffixIcon,
    bool filled = true,
    String field,
  }) {
    return InputDecoration(
      suffixIcon: suffixIcon,
      contentPadding: field == "check"
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(
              horizontal: 10,
            ),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: const BorderRadius.all(
          const Radius.circular(6.0),
        ),
      ),
      hintText: !withLabel ? label : null,
      filled: filled,
      fillColor: Palette.fieldBgColor,
    );
  }
}
