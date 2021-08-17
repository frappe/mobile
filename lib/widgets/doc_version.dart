import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/model/offline_storage.dart';
import 'package:html/parser.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../utils/dio_helper.dart';
import '../utils/helpers.dart';
import '../utils/http.dart';

class DocVersion extends StatelessWidget {
  final Map version;

  DocVersion(this.version);

  @override
  Widget build(BuildContext context) {
    var txt = "";

    var time = timeago.format(DateTime.parse(version["creation"]));
    var author = version["owner"];

    var allUsers = OfflineStorage.getItem('allUsers');
    allUsers = allUsers["data"];
    if (allUsers != null) {
      var user = allUsers[author];

      if (user != null) {
        author = user["full_name"];
      } else {
        author = "Support Bot";
      }
    }
    if (version["data"] != null) {
      final decoded = json.decode(version["data"]);
      var changed = decoded["changed"];
      var createdBy = decoded["created_by"];
      var stringMaxSize = 50;

      if (changed != null) {
        txt = "<div><b>$author</b> changed value of ";

        changed.forEach((c) {
          String fromVal;
          String toVal;
          if (c[1] == null || c[1] == "") {
            fromVal = '""';
          } else {
            fromVal = parse(c[1].toString()).documentElement?.text ?? "";
            if (fromVal.length > stringMaxSize) {
              fromVal = fromVal.substring(0, stringMaxSize) + "...";
            }
          }

          if (c[2] == null || c[2] == "") {
            toVal = '""';
          } else {
            toVal = parse(c[2].toString()).documentElement?.text ?? "";
            if (toVal.length > stringMaxSize) {
              toVal = toVal.substring(0, stringMaxSize) + "...";
            }
          }

          if (fromVal == "") {
            fromVal = '""';
          }

          if (toVal == "") {
            toVal = '""';
          }

          txt += "${toTitleCase(c[0])} from <b>$fromVal</b> to <b>$toVal</b> ";
        });
      } else if (createdBy != null) {
        txt = "<div><b>$createdBy</b> created";
      }
    } else if (version["_category"] == "views") {
      txt = "<div><b>$author</b> viewed";
    }

    txt += "<p><span>$time</span></p></div>";

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 4.0,
        top: 4.0,
        left: 1,
      ),
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
        onLinkTap: (a, b, c, d) async {
          print("a $a");
          print("b $b");
          print("c $c");
          print("d $d");
          // TODO
          // final absoluteUrl = getAbsoluteUrl(url);
          // if (await canLaunch(absoluteUrl)) {
          //   await launch(
          //     absoluteUrl,
          //     headers: {HttpHeaders.cookieHeader: await DioHelper.getCookies()},
          //   );
          // } else {
          //   throw 'Could not launch $url';
          // }
        },
        // onLinkTap: (url, context, __) {

        // },
      ),
    );
  }
}
