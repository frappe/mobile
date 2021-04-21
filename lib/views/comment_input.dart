import 'package:flutter/material.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/model/config.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/widgets/frappe_button.dart';

import '../app/locator.dart';

import '../services/api/api.dart';

class CommentInput extends StatelessWidget {
  final String doctype;
  final String name;
  final Function callback;

  CommentInput({
    required this.doctype,
    required this.name,
    required this.callback,
  });

  final TextEditingController input = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextEditingController _input = TextEditingController();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _input,
              maxLines: null,
              decoration:
                  Palette.formFieldDecoration(label: "", withLabel: true),
            ),
            SizedBox(
              height: 10,
            ),
            FrappeFlatButton(
              buttonType: ButtonType.primary,
              onPressed: () async {
                if (_input.text.isNotEmpty) {
                  await locator<Api>().postComment(
                    doctype,
                    name,
                    _input.text,
                    Config().user,
                  );
                  callback();
                }
              },
              title: "comment",
            )
          ],
        ),
      ),
    );
  }
}
