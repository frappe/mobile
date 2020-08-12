import 'package:flutter/material.dart';

import '../config/frappe_icons.dart';
import '../utils/frappe_icon.dart';
import '../widgets/assignees.dart';
import '../widgets/attachments.dart';

class ViewDocInfo extends StatelessWidget {
  final Map docInfo;
  final String doctype;
  final String name;
  final Function callback;

  ViewDocInfo({
    @required this.doctype,
    @required this.name,
    @required this.docInfo,
    this.callback,
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
          ],
        ),
      ),
    );
  }
}
