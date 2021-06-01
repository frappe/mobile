import 'package:flutter/material.dart';

class FrappePalette {
  static List<MaterialColor> colors = [
    grey,
    blue,
    yellow,
    darkGreen,
    red,
    orange,
  ];

  static const MaterialColor grey = MaterialColor(
    _greyPrimaryValue,
    <int, Color>{
      50: Color(0xFFF9FAFA),
      100: Color(0xFFF4F5F6),
      200: Color(0xFFEEF0F2),
      300: Color(0xFFE2E6E9),
      400: Color(0xFFC8CFD5),
      500: Color(_greyPrimaryValue),
      600: Color(0xFF74808B),
      700: Color(0xFF4C5A67),
      800: Color(0xFF313B44),
      900: Color(0xFF192734),
    },
  );
  static const int _greyPrimaryValue = 0xFFA6B1B9;

  static const MaterialColor blue = MaterialColor(
    _bluePrimaryValue,
    <int, Color>{
      50: Color(0xFFF5FAFF),
      100: Color(0xFFEBF5FF),
      200: Color(0xFFBFDDF7),
      300: Color(0xFF90C5F4),
      400: Color(0xFF62B2F9),
      500: Color(_bluePrimaryValue),
      600: Color(0xFF318AD8),
      700: Color(0xFF096CC3),
      800: Color(0xFF2C5477),
      900: Color(0xFF2A4965),
    },
  );
  static const int _bluePrimaryValue = 0XFF2D95F0;

  static const MaterialColor red = MaterialColor(
    _redPrimaryValue,
    <int, Color>{
      50: Color(0xFFFEF6F6),
      100: Color(0xFFFEECEC),
      200: Color(0xFFF6DFDF),
      300: Color(0xFFFEB9B9),
      400: Color(0xFFFC8888),
      500: Color(_redPrimaryValue),
      600: Color(0xFFE24C4C),
      700: Color(0xFFC53B3B),
      800: Color(0xFF9B4646),
      900: Color(0xFF742525),
    },
  );
  static const int _redPrimaryValue = 0xFFF56B6B;

  static const MaterialColor orange = MaterialColor(
    _orangePrimaryValue,
    <int, Color>{
      50: Color(0xFFFFF5F0),
      100: Color(0xFFFFEAE1),
      200: Color(0xFFFECDB8),
      300: Color(0xFFFDAE8C),
      400: Color(0xFFF9966C),
      500: Color(_orangePrimaryValue),
      600: Color(0xFFCB5A2A),
      700: Color(0xFF9C4621),
      800: Color(0xFF7B3A1E),
      900: Color(0xFF653019),
    },
  );
  static const int _orangePrimaryValue = 0xFFF8814F;

  static const MaterialColor yellow = MaterialColor(
    _yellowPrimaryValue,
    <int, Color>{
      50: Color(0xFFFDF9F2),
      100: Color(0xFFFEF4E2),
      200: Color(0xFFFEE9BF),
      300: Color(0xFFFCDA97),
      400: Color(0xFFFACF7A),
      500: Color(_yellowPrimaryValue),
      600: Color(0xFFD6932E),
      700: Color(0xFFCA8012),
      800: Color(0xFF976417),
      900: Color(0xFF744C11),
    },
  );
  static const int _yellowPrimaryValue = 0xFFECAC4B;

  static const MaterialColor darkGreen = MaterialColor(
    _darkGreenPrimaryValue,
    <int, Color>{
      50: Color(0xFFF5FAF7),
      100: Color(0xFFEEF7F1),
      200: Color(0xFFC6F1D6),
      300: Color(0xFF9AE5B6),
      400: Color(0xFF68D391),
      500: Color(_darkGreenPrimaryValue),
      600: Color(0xFF38A160),
      700: Color(0xFF1B984B),
      800: Color(0xFF276840),
      900: Color(0xFF225335),
    },
  );
  static const int _darkGreenPrimaryValue = 0xFF48BB74;
}
