import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
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

  @override
  Widget build(BuildContext context) {
    var time = timeago.format(DateTime.parse(widget.data["creation"]));
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Palette.lightGrey,
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: 30,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Palette.lightGrey,
                  width: 0.5,
                ),
              ),
              color: Palette.offWhite
            ),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 5),
                ),
                Icon(
                  Icons.comment,
                  size: 18,
                  color: Palette.darkGrey
                ),
                SizedBox(
                  width: 4,
                ),
                Text(
                  '${widget.data["owner"]} - $time',
                  style: TextStyle(color: Palette.darkGrey),
                ),
                Spacer(),
                ButtonTheme(
                  minWidth: 1.0,
                  child: FlatButton(
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
                                    await _deleteComment(widget.data["name"]);
                                    Navigator.of(context).pop();
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
                    },
                    child: Icon(
                      Icons.delete,
                      size: 20,
                      color: Palette.darkGrey
                    ),
                  ),
                ),
                ButtonTheme(
                  minWidth: 1.0,
                  child: FlatButton(
                    onPressed: () {},
                    child: Text(
                      "Edit",
                      style: TextStyle(color: Palette.darkGrey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 30,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Html(
                    data: widget.data["content"],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
