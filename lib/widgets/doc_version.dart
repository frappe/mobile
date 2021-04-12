import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/model/get_doc_response.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../config/palette.dart';

import '../utils/dio_helper.dart';
import '../utils/helpers.dart';
import '../utils/http.dart';

class DocVersion extends StatelessWidget {
  final Version version;

  DocVersion(this.version);

  @override
  Widget build(BuildContext context) {
    String txt;

    var time = timeago.format(DateTime.parse(version.creation));
    if (version.data != null) {
      final decoded = json.decode(version.data);
      var changed = decoded["changed"];
      var author = version.owner;
      var createdBy = decoded["created_by"];

      if (changed != null) {
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
      } else if (createdBy != null) {
        txt = "<div><b>$createdBy</b> created";
      }
    }

    txt += "</br><span>$time</span></div>";

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, top: 4.0),
      child: Html(
        data: txt,
        style: {
          "div": Style(
            fontSize: FontSize(12),
          ),
          "span": Style(
            color: FrappePalette.grey[600],
          ),
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
              headers: {HttpHeaders.cookieHeader: await DioHelper.getCookies()},
            );
          } else {
            throw 'Could not launch $url';
          }
        },
      ),
    );
  }
}
