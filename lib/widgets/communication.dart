import 'package:flutter/material.dart';

import '../widgets/timeline.dart';

class Communication extends StatefulWidget {
  final Map docInfo;
  final String name;
  final String doctype;
  final Function callback;

  const Communication({this.docInfo, this.doctype, this.name, this.callback});

  @override
  _CommunicationState createState() => _CommunicationState();
}

class _CommunicationState extends State<Communication> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Timeline(widget.docInfo, widget.callback),
          ]),
    );
  }
}