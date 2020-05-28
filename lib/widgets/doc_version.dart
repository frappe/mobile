import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:frappe_app/utils/helpers.dart';
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

      txt = "<b>$author</b> changed value of ";
    
      changed.forEach((c) {
        var fromVal;
        var toVal;
        if (c[1] == null || c[1] == "") {
          fromVal = '""';
        } else {
          fromVal = c[1];
        }

        if (c[2] == null || c[2] == "") {
          toVal = '""';
        } else {
          toVal = c[2];
        }

        txt += "${toTitleCase(c[0])} from <b>$fromVal</b> to <b>$toVal</b> ";
      });
    } else if (data["comment_type"] == "Attachment") {
      txt = "<b>${data["owner"]}</b> ${data["content"]}";
    } else {
      txt = data["content"];
    }

    return Card(
      child: ListTile(
        subtitle: Text(time),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Html(
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
        ),
      ),
    );
  }
}
