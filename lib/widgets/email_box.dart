import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:frappe_app/app/locator.dart';
import 'package:frappe_app/app/router.gr.dart';
import 'package:frappe_app/services/navigation_service.dart';

import 'package:html/parser.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../config/palette.dart';

import '../model/config.dart';

import '../widgets/user_avatar.dart';

class EmailBox extends StatelessWidget {
  final Map data;

  EmailBox(this.data);

  @override
  Widget build(BuildContext context) {
    var time = timeago.format(DateTime.parse(data["creation"]));

    var document = parse(data["content"]);
    String parsedContent = parse(document.body.text).documentElement.text;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          onTap: () {
            locator<NavigationService>().navigateTo(
              Routes.viewEmail,
              arguments: ViewEmailArguments(
                time: time,
                title: data["subject"],
                senderFullName: data["sender_full_name"],
                sender: data["sender"],
                content: data["content"],
              ),
            );
          },
          subtitle:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
              child: Text(
                data["subject"],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black),
              ),
            ),
            Text(
              parsedContent,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          ]),
          title: Row(
            children: [
              Text('${data["sender_full_name"]}'),
              Spacer(),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ViewEmail extends StatelessWidget {
  final String title;
  final String time;
  final String senderFullName;
  final String sender;
  final String content;

  ViewEmail({
    @required this.title,
    @required this.time,
    @required this.senderFullName,
    @required this.sender,
    @required this.content,
  });

  @override
  Widget build(BuildContext context) {
    var document = parse(content);
    var imgs = document.getElementsByTagName('img');

    imgs.forEach((img) {
      if (Uri.parse(img.attributes["src"]).hasAbsolutePath) {
        img.attributes["src"] = "${Config().baseUrl}${img.attributes["src"]}";
      }
    });

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              elevation: 4,
              child: Container(
                color: Palette.bgColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    ListTile(
                      leading: UserAvatar(
                        uid: sender,
                      ),
                      title: Text(senderFullName),
                      subtitle: Text(time),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8.0),
              child: Html(data: document.outerHtml),
            )
          ],
        ),
      ),
    );
  }
}
