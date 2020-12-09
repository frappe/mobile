import 'package:flutter/material.dart';

import '../app/locator.dart';

import '../services/backend_service.dart';
import '../services/navigation_service.dart';

class CommentInput extends StatelessWidget {
  final String doctype;
  final String name;
  final String authorEmail;
  final Function callback;

  CommentInput({
    @required this.doctype,
    @required this.name,
    @required this.authorEmail,
    @required this.callback,
  });

  final TextEditingController input = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextEditingController _input = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () async {
              if (_input.text.isEmpty) {
                return;
              }
              await BackendService.postComment(
                doctype,
                name,
                _input.text,
                authorEmail,
              );
              callback();
              locator<NavigationService>().pop();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          autofocus: true,
          controller: _input,
          maxLines: 9999999,
        ),
      ),
    );
  }
}
