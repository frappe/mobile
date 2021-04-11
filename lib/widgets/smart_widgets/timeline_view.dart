import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/model/get_doc_response.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/base_view.dart';
import 'package:frappe_app/views/email_form.dart';
import 'package:frappe_app/widgets/doc_version.dart';
import 'package:frappe_app/widgets/email_box.dart';
import 'package:frappe_app/widgets/smart_widgets/timeline_viewmodel.dart';

import '../../config/palette.dart';
import '../comment_box.dart';

class TimelineView extends StatelessWidget {
  final Docinfo docinfo;
  final String doctype;
  final String name;
  final String emailSubjectField;
  final String emailSenderField;

  TimelineView({
    @required this.docinfo,
    @required this.doctype,
    @required this.name,
    @required this.emailSenderField,
    @required this.emailSubjectField,
  });

  @override
  Widget build(BuildContext context) {
    return BaseView<TimelineViewModel>(
      onModelReady: (model) {
        model.docinfo = docinfo;
        model.doctype = doctype;
        model.name = name;
        model.communicationOnly = true;
        model.processData();
      },
      builder: (context, model, child) {
        List<Widget> children = [
          Row(
            children: [
              Text('Activity'),
              Spacer(),
              Switch.adaptive(
                value: model.communicationOnly,
                activeColor: Colors.blue,
                onChanged: (val) {
                  model.toggleSwitch(val);
                },
              ),
              Text("Communication Only"),
            ],
          ),
        ];

        children.add(
          Row(
            children: [
              FlatButton.icon(
                color: FrappePalette.grey[600],
                shape: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(6),
                  ),
                ),
                label: Text(
                  'New Email',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                icon: FrappeIcon(
                  FrappeIcons.email,
                ),
                onPressed: () {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return EmailForm(
                          callback: () {
                            model.refreshDocinfo();
                          },
                          subjectField: emailSubjectField,
                          senderField: emailSenderField,
                          doctype: doctype,
                          doc: name,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );

        for (var event in model.events) {
          if (event["_category"] == "versions") {
            event = Version.fromJson(event);
          } else if (event["_category"] == "communications") {
            event = Communication.fromJson(event);
          } else if (event["_category"] == "comments") {
            event = Comment.fromJson(event);
          }

          if (event is Communication) {
            children.add(EmailBox(event));
          } else if (event is Comment) {
            children.add(
              CommentBox(
                event,
                () {
                  model.refreshDocinfo();
                },
              ),
            );
          } else {
            if (model.communicationOnly) {
              continue;
            }
            children.add(DocVersion(event));
          }
        }

        return Container(
          color: Palette.bgColor,
          child: ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.all(8),
            itemCount: children.length,
            itemBuilder: (BuildContext context, int index) {
              return children[index];
            },
            separatorBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.all(4),
              );
            },
          ),
        );
      },
    );
  }
}
