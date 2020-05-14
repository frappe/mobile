import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:support_app/config/palette.dart';
import 'package:timeago/timeago.dart' as timeago;

class DocVersion extends StatelessWidget {
  final Map data;

  DocVersion(this.data);

  @override
  Widget build(BuildContext context) {
    String txt;

    var time = timeago.format(DateTime.parse(data["creation"]));
    if (data["data"] != null) {
      final decoded = json.decode(data["data"]);
      var changed = decoded["changed"];
      var author = data["owner"];

      txt = "$author changed value of ";

      changed.forEach((c) {
        txt += "${c[0]} from ${c[1]} to ${c[2]} ";
      });
    } else if (data["comment_type"] == "Attachment") {
      txt = "${data["owner"]} ${data["content"]}";
    } else {
      txt = "Unhandled txt";
    }

    txt += "- $time";

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Palette.lightGrey,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.edit,
            size: 20,
            color: Palette.lightGrey,
          ),
          Expanded(
            child: Html(data: txt),
          ),
        ],
      ),
    );
  }
}
