import 'package:flutter/material.dart';
import 'package:frappe_app/config/palette.dart';

class Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  Section({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title != '')
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              title.toUpperCase(),
              style: Palette.secondaryTxtStyle,
            ),
          ),
        ...children,
      ],
    );
  }
}
