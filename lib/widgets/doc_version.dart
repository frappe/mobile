import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../config/palette.dart';
import '../utils/http.dart';

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

    // txt += "- $time";

    return Card(
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: Palette.lightGrey,
      //   ),
      // ),
      // padding: EdgeInsets.fromLTRB(10,10,10,20),
      child: ListTile(
        // crossAxisAlignment: CrossAxisAlignment.start,
        subtitle: Text(time),
        title: Html(
          data: txt,
          onImageError: (a, b) {
            // TODO
            print(a);
            print(b);
          },
          onLinkTap: (url) async {
            final absoluteUrl = getAbsoluteUrl(url);
            if (await canLaunch(absoluteUrl)) {
              await launch(
                absoluteUrl,
                headers: await getCookiesWithHeader(),
              );
            } else {
              throw 'Could not launch $url';
            }
          },
        ),
        // Icon(
        //   Icons.edit,
        //   size: 20,
        //   color: Palette.lightGrey,
        // ),
        // Expanded(
        //   child:
        // ),
      ),
    );
  }
}
