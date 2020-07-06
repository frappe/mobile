import 'package:flutter/material.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/utils/enums.dart';

class Button extends StatelessWidget {
  final Function onPressed;
  final String title;
  final IconData icon;
  final ButtonType buttonType;

  Button({
    @required this.onPressed,
    @required this.title,
    this.icon,
    @required this.buttonType,
  });

  @override
  Widget build(BuildContext context) {
    Color _buttonColor;
    TextStyle _textStyle;

    if (onPressed == null) {
      _buttonColor = Palette.disabledButonColor;
      _textStyle = TextStyle(
        color: Colors.white,
      );
    } else if (buttonType == ButtonType.primary) {
      _buttonColor = Palette.primaryButtonColor;
      _textStyle = TextStyle(
        color: Colors.white,
      );
    } else if (buttonType == ButtonType.secondary) {
      _buttonColor = Palette.secondaryButtonColor;
      _textStyle = TextStyle(
        color: Colors.black,
      );
    }

    if (icon != null) {
      return ButtonTheme(
        height: 32,
        child: FlatButton.icon(
          label: Text(
            title,
            style: _textStyle,
          ),
          icon: Icon(icon),
          onPressed: onPressed,
          shape: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(6),
            ),
          ),
          color: _buttonColor,
          disabledColor: _buttonColor,
        ),
      );
    } else {
      return ButtonTheme(
        height: 32,
        child: FlatButton(
          onPressed: onPressed,
          shape: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(6),
            ),
          ),
          color: _buttonColor,
          disabledColor: _buttonColor,
          child: Text(title, style: _textStyle),
        ),
      );
    }
  }
}
