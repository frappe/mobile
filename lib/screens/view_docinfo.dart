import 'package:flutter/material.dart';
import 'package:frappe_app/widgets/reviews.dart';
import 'package:frappe_app/widgets/shared_with.dart';
import 'package:frappe_app/widgets/tags.dart';

import '../config/frappe_icons.dart';
import '../utils/frappe_icon.dart';
import '../widgets/assignees.dart';
import '../widgets/attachments.dart';

class ViewDocInfo extends StatelessWidget {
  final Map docInfo;
  final String doctype;
  final String name;
  final Function callback;
  final Map meta;
  final Map doc;

  ViewDocInfo({
    @required this.doctype,
    @required this.name,
    @required this.docInfo,
    this.callback,
    @required this.meta,
    @required this.doc,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            Row(
              children: <Widget>[
                FrappeIcon(FrappeIcons.assign),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Assigned To',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Assignees(
              doctype: doctype,
              name: name,
              callback: callback,
              docInfo: docInfo,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                FrappeIcon(FrappeIcons.attachment),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Attachments',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Attachments(
              doctype: doctype,
              name: name,
              callback: callback,
              docInfo: docInfo,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                FrappeIcon(FrappeIcons.tag),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Tags',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Tags(
              doctype: doctype,
              name: name,
              callback: callback,
              docInfo: docInfo,
            ),
            SizedBox(
              height: 20,
            ),
            if (docInfo["energy_point_logs"] != null)
              Row(
                children: <Widget>[
                  FrappeIcon(FrappeIcons.review),
                  SizedBox(
                    width: 6,
                  ),
                  Text(
                    'Reviews',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            if (docInfo["energy_point_logs"] != null)
              SizedBox(
                height: 10,
              ),
            if (docInfo["energy_point_logs"] != null)
              Reviews(
                doctype: doctype,
                meta: meta,
                doc: doc,
                name: name,
                callback: callback,
                docInfo: docInfo,
              ),
            if (docInfo["energy_point_logs"] != null)
              SizedBox(
                height: 20,
              ),
            Row(
              children: <Widget>[
                FrappeIcon(FrappeIcons.share),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Shared With',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            SharedWith(
              doctype: doctype,
              name: name,
              callback: callback,
              docInfo: docInfo,
            ),
          ],
        ),
      ),
    );
  }
}
