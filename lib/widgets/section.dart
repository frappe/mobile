import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  Section({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != '')
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}
