import 'package:flutter/material.dart';
import '../utils/enums.dart';
import '../widgets/comment_box.dart';
import '../widgets/doc_version.dart';
import '../widgets/email_box.dart';

class Event extends StatelessWidget {
  final EventType eventType;
  final data;
  final Function callback;

  Event(this.eventType, this.data, this.callback);

  @override
  Widget build(BuildContext context) {
    Widget val;

    switch (eventType) {
      case EventType.comment:
        val = CommentBox(data, callback);
        break;

      case EventType.email:
        val = EmailBox(data);
        break;

      case EventType.docVersion:
        val = DocVersion(data);
        break;

      default:
        break;
    }

    return val;
  }
}
