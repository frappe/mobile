import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../app/locator.dart';
import '../model/config.dart';

import '../services/api/api.dart';
import '../services/navigation_service.dart';

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
                  locator<NavigationService>().pop();
                  locator<Api>().deleteComment(data["name"]);
                  callback();
                },
              ),
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  locator<NavigationService>().pop();
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
            trailing: Config().user == data["owner"]
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
