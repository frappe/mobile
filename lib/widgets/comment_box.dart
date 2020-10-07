import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../utils/backend_service.dart';
import '../utils/config_helper.dart';

class CommentBox extends StatelessWidget {
  final Map data;
  final Function callback;

  CommentBox(this.data, this.callback);

  void _choiceAction(
    BuildContext context,
    String choice,
  ) {
    if (choice == 'Delete') {
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
                  BackendService.deleteComment(data["name"]);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    var time = timeago.format(DateTime.parse(data["creation"]));

    return Card(
      elevation: 0,
      child: Column(
        children: [
          ListTile(
            title: Text('${data["owner"]}'),
            subtitle: Text(time),
            trailing: ConfigHelper().user == data["owner"]
                ? PopupMenuButton(
                    onSelected: (choice) {
                      _choiceAction(context, choice);
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: Text('Delete'),
                          value: "Delete",
                        )
                      ];
                    },
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Html(
              data: data["content"],
            ),
          ),
        ],
      ),
    );
  }
}
