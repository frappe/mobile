import 'package:flutter/material.dart';
import 'package:frappe_app/config/palette.dart';

import '../widgets/timeline.dart';

class Communication extends StatefulWidget {
  final List docInfo;
  final Function callback;

  const Communication({this.docInfo, this.callback});

  @override
  _CommunicationState createState() => _CommunicationState();
}

class _CommunicationState extends State<Communication> {
  @override
  Widget build(BuildContext context) {
    // return Timeline(widget.docInfo, widget.callback);
    return Container(
      color: Palette.bgColor,
      child: ListView(
        children: <Widget>[
          Timeline(widget.docInfo, widget.callback),
        ],
      ),
    );
  }
}
