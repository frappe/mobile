import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
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

      txt = "<div><b>$author</b> changed value of ";

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
      txt = "<div><b>${data["owner"]}</b> ${data["content"]}";
    } else if (data["comment_type"] == "Like") {
      txt = "<div>${data["content"]} by ${data["owner"]}";
    } else {
      txt = "<div>${data["content"]}";
    }

    txt += "<span> - $time</span></div>";

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, top: 4.0),
      child: Html(
        data: txt,
        style: {
          "div": Style(
            fontSize: FontSize(12),
          ),
          "span": Style(
            color: Palette.dimTxtColor
          )
        },
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
    );
  }
}
