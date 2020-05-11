import 'package:flutter/material.dart';
import 'package:support_app/utils/enums.dart';
import 'package:support_app/widgets/comment_box.dart';
import 'package:support_app/widgets/doc_version.dart';
import 'package:support_app/widgets/email_box.dart';

class Event extends StatelessWidget {
  final EventType eventType;
  final data;
  final Function callback;

  Event(this.eventType, this.data, this.callback);

  Widget _eventWidget(EventType eventType, Map data, [Function callback]) {
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

      // case EventType.newEmail:
      //   val = RaisedButton(
      //     onPressed: () {},
      //     child: Text('New Email'),
      //   );
      //   break;

      default:
        break;
    }

    return val;
  }

  @override
  Widget build(BuildContext context) {
    return _eventWidget(eventType, data, callback);
    // return Row(
    //     children: <Widget>[
    //       Container(
    //         width: 20,
    //         child: Stack(
    //           children: <Widget>[
    //             Container(
    //               height: 100,
    //               child: VerticalDivider(
    //                 thickness: 2,
    //               ),
    //             ),
    //             Positioned(
    //               top: 40,
    //               child: Icon(
    //                 Icons.lens,
    //                 size: 15,
    //                 color: Colors.black26,
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //       Expanded(
    //         child: _eventWidget(eventType, data),
    //       ),
    //     ],
    // );
  }
}
