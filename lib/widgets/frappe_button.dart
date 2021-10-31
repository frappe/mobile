import 'package:flutter/material.dart';

import '../config/palette.dart';
import '../utils/enums.dart';
import '../utils/frappe_icon.dart';

class FrappeFlatButton extends StatelessWidget {
  final void Function()? onPressed;
  final String title;
  final ButtonType buttonType;
  final String? icon;
  final double height;
  final double minWidth;
  final bool fullWidth;

  FrappeFlatButton({
    required this.onPressed,
    required this.buttonType,
    required this.title,
    this.icon,
    this.height = 36.0,
    this.minWidth = 88,
    this.fullWidth = false,
  });

  FrappeFlatButton.small({
    required this.onPressed,
    required this.buttonType,
    required this.title,
    this.icon,
    this.height = 32.0,
    this.minWidth = 88,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    late Color _buttonColor;
    late TextStyle _textStyle;

    if (onPressed == null) {
      _buttonColor = Palette.disabledButonColor;
      _textStyle =
          TextStyle(color: Colors.white, fontSize: fullWidth ? 18 : null);
    } else if (buttonType == ButtonType.primary) {
      _buttonColor = Palette.primaryButtonColor;
      _textStyle =
          TextStyle(color: Colors.white, fontSize: fullWidth ? 18 : null);
    } else {
      _buttonColor = Palette.secondaryButtonColor;
      _textStyle =
          TextStyle(color: Colors.black, fontSize: fullWidth ? 18 : null);
    }

    if (icon != null) {
      return ButtonTheme(
        height: height,
        minWidth: fullWidth ? double.infinity : minWidth,
        child: FlatButton.icon(
          label: Text(
            title,
            style: _textStyle,
          ),
          icon: FrappeIcon(icon!),
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
        height: height,
        minWidth: fullWidth ? double.infinity : minWidth,
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
            child: Text(
              title,
              style: _textStyle,
            )),
      );
    }
  }
}

class FrappeRaisedButton extends StatelessWidget {
  final void Function()? onPressed;
  final String? title;
  final Widget? titleWidget;
  final String? icon;
  final double height;
  final double minWidth;
  final Color color;
  final double? iconSize;
  final bool fullWidth;

  FrappeRaisedButton({
    required this.onPressed,
    this.titleWidget,
    this.title,
    this.icon,
    this.iconSize,
    this.height = 36.0,
    this.color = Colors.white,
    this.minWidth = 88,
    this.fullWidth = false,
  });

  FrappeRaisedButton.small({
    required this.onPressed,
    this.title,
    this.titleWidget,
    this.icon,
    this.iconSize,
    this.height = 32.0,
    this.color = Colors.white,
    this.minWidth = 88,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget tWidget;
    if (title != null) {
      tWidget = Text(title!);
    } else if (titleWidget != null) {
      tWidget = titleWidget!;
    } else {
      tWidget = Text('');
    }

    if (icon != null) {
      return ButtonTheme(
        height: height,
        minWidth: fullWidth ? double.infinity : minWidth,
        child: RaisedButton.icon(
          color: color,
          label: tWidget,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          icon: FrappeIcon(
            icon!,
            size: iconSize,
          ),
          onPressed: onPressed,
        ),
      );
    } else {
      return ButtonTheme(
        height: height,
        minWidth: fullWidth ? double.infinity : minWidth,
        child: RaisedButton(
          color: color,
          onPressed: onPressed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: tWidget,
        ),
      );
    }
  }
}

class FrappeIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final ButtonType buttonType;
  final String icon;
  final double height;
  final double minWidth;
  final bool fullWidth;

  FrappeIconButton({
    required this.onPressed,
    required this.buttonType,
    required this.icon,
    this.height = 36.0,
    this.minWidth = 88,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    Color _buttonColor;

    if (onPressed == null) {
      _buttonColor = Palette.disabledButonColor;
    } else if (buttonType == ButtonType.primary) {
      _buttonColor = Palette.primaryButtonColor;
    } else {
      _buttonColor = Palette.secondaryButtonColor;
    }

    return Container(
      decoration: BoxDecoration(
        color: _buttonColor,
        borderRadius: BorderRadius.all(
          Radius.circular(6),
        ),
      ),
      child: ButtonTheme(
        height: height,
        minWidth: fullWidth ? double.infinity : minWidth,
        child: IconButton(
          icon: FrappeIcon(icon),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
