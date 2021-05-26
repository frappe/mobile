import 'package:flutter/material.dart';

class NavigationHelper {
  static clearAllAndNavigateTo({
    required BuildContext context,
    required Widget page,
    bool withNavBar = false,
  }) {
    Navigator.of(context, rootNavigator: !withNavBar).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) {
        return page;
      }),
      (_) => false,
    );
  }

  static push({
    required BuildContext context,
    required Widget page,
    bool withNavBar = false,
  }) {
    Navigator.of(context, rootNavigator: !withNavBar).push(
      MaterialPageRoute(builder: (context) {
        return page;
      }),
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
