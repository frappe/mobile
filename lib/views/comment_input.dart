import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/model/config.dart';
import 'package:frappe_app/model/offline_storage.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/widgets/frappe_button.dart';
import 'package:frappe_app/widgets/user_avatar.dart';

import '../app/locator.dart';

import '../services/api/api.dart';

class CommentInput extends StatefulWidget {
  final String doctype;
  final String name;
  final Function callback;

  CommentInput({
    required this.doctype,
    required this.name,
    required this.callback,
  });

  @override
  _CommentInputState createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  @override
  Widget build(BuildContext context) {
    GlobalKey<FlutterMentionsState> key = GlobalKey<FlutterMentionsState>();
    Map users = OfflineStorage.getItem('allUsers')["data"];
    var userList = users.values.map<Map<String, dynamic>>((e) {
      e["display"] = e["full_name"];
      e["id"] = e["name"];
      return Map<String, dynamic>.from(e);
    }).toList();

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlutterMentions(
            key: key,
            suggestionPosition: SuggestionPosition.Top,
            maxLines: 5,
            minLines: 2,
            decoration: Palette.formFieldDecoration(),
            mentions: [
              Mention(
                markupBuilder: (String trigger, String mention, String value) {
                  return '<span class="mention" data-id="$mention"' +
                      'data-value="<a href=&quot;${Config().baseUrl}/app/user-profile/$mention&quot; target=&quot;_blank&quot;' +
                      '>$value" data-denotation-char="@" data-is-group="false"' +
                      'data-link="${Config().baseUrl}/app/user-profile/$mention">' +
                      '<span contenteditable="false"><span class="ql-mention-denotation-char">' +
                      '@</span><a href="${Config().baseUrl}/app/user-profile/$mention"' +
                      'target="_blank">$value</a></span></span>';
                },
                trigger: '@',
                style: TextStyle(
                  color: FrappePalette.blue,
                ),
                data: userList,
                matchAll: false,
                suggestionBuilder: (user) {
                  return Container(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        UserAvatar(
                          uid: user["name"],
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        Text(user['full_name']),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          FrappeFlatButton(
            buttonType: ButtonType.primary,
            onPressed: () async {
              if (key.currentState!.controller!.markupText.isNotEmpty) {
                var htmlString = '<div class="ql-editor read-mode"><p>' +
                    key.currentState!.controller!.markupText +
                    '</p></div>';
                await locator<Api>().postComment(
                  widget.doctype,
                  widget.name,
                  htmlString,
                  Config().user,
                );
                widget.callback();
              }
            },
            title: "Comment",
          )
        ],
      ),
    );
  }
}
