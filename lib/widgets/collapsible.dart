import 'package:flutter/material.dart';

class Collapsible extends StatefulWidget {
  final String header;
  final List items;

  Collapsible(this.header, this.items);

  @override
  _CollapsibleState createState() => _CollapsibleState();
}

class _CollapsibleState extends State<Collapsible> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: ExpansionTile(
          title: Text(widget.header),
          children: <Widget>[
            new Checkbox(value: true, onChanged: null),
            new Checkbox(value: false, onChanged: null),
          ],
        ),
      ),
    );
  }
}
