import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_palette.dart';

AppBar buildAppBar({
  @required String title,
  bool expanded = false,
  List<Widget> actions,
  Function onPressed,
  bool isRoot = false,
}) {
  double titleSpacing;

  if (isRoot || expanded) {
    titleSpacing = NavigationToolbar.kMiddleSpacing;
  } else {
    titleSpacing = 0.0;
  }
  return AppBar(
    elevation: expanded ? 0 : 0.8,
    automaticallyImplyLeading: !expanded,
    titleSpacing: titleSpacing,
    title: FlatButton(
      visualDensity: VisualDensity(
        horizontal: -4,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: FrappePalette.grey[900],
              fontSize: 18,
            ),
          ),
          expanded
              ? Icon(
                  Icons.expand_less,
                )
              : Icon(
                  Icons.expand_more,
                ),
        ],
      ),
    ),
    actions: actions,
  );
}
