import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:frappe_app/main.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../config/palette.dart';
import '../utils/http.dart';

class CommentBox extends StatefulWidget {
  final Map data;
  final Function callback;

  CommentBox(this.data, this.callback);

  @override
  _CommentBoxState createState() => _CommentBoxState();
}

class _CommentBoxState extends State<CommentBox> {
  Future<void> _deleteComment(name) async {
    var queryParams = {
      'doctype': 'Comment',
      'name': name,
    };

    final response2 = await dio.post('/method/frappe.client.delete',
        data: queryParams,
        options: Options(contentType: Headers.formUrlEncodedContentType));
    if (response2.statusCode == 200) {
      return;
      // If the server did return a 200 OK response,
      // then parse the JSON.
      // return DioResponse.fromJson(response2.data);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  void _choiceAction(String choice) {
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
                    await _deleteComment(widget.data["name"]);
                    widget.callback();
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
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    var time = timeago.format(DateTime.parse(widget.data["creation"]));

    return Card(
      elevation: 0,
      child: Column(
        children: [
          ListTile(
            title: Text('${widget.data["owner"]}'),
            subtitle: Text(time),
            trailing: localStorage.getString('user') == widget.data["owner"]
                ? PopupMenuButton(
                    onSelected: _choiceAction,
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
              data: widget.data["content"],
            ),
          ),
        ],
      ),
    );
  }
}
