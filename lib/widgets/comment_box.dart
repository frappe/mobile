import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/model/get_doc_response.dart';
import 'package:frappe_app/model/offline_storage.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../app/locator.dart';
import '../model/config.dart';

import '../services/api/api.dart';

class CommentBox extends StatelessWidget {
  final Comment data;
  final Function callback;

  CommentBox(this.data, this.callback);

  @override
  Widget build(BuildContext context) {
    var time = timeago.format(DateTime.parse(data.creation));
    String commenterName;
    var allUsers = OfflineStorage.getItem('allUsers');
    allUsers = allUsers["data"];

    if (allUsers != null) {
      var user = allUsers[data.owner];
      if (user != null) {
        commenterName = user["full_name"];
      } else {
        commenterName = data.owner;
      }
    } else {
      commenterName = data.owner;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 2.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
              title: Text(
                '$commenterName',
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
              subtitle: Text("commented $time"),
              trailing: Config().userId == data.owner
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      icon: FrappeIcon(
                        FrappeIcons.close_alt,
                        size: 16,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Are you sure'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Yes'),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await locator<Api>()
                                        .deleteComment(data.name);
                                    callback();
                                  },
                                ),
                                FlatButton(
                                  child: Text('No'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          },
                        );
                      },
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Html(
                data: data.content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
