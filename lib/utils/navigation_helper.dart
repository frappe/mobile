import 'package:flutter/material.dart';

class NavigationHelper {
  static clearAllAndNavigateTo({
    required BuildContext context,
    required Widget page,
  }) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) {
        return page;
      }),
      (_) => false,
    );
  }

  static pushReplacement({
    required BuildContext context,
    required Widget page,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return page;
        },
      ),
    );
  }
}
