import 'package:flutter/material.dart';

import '../utils/enums.dart';
import '../widgets/event.dart';

class Timeline extends StatelessWidget {
  final Map data;
  final Function callback;

  Timeline(this.data, this.callback);

  List sortByDate(List data, String orderBy, Order order) {
    if (order == Order.asc) {
      data.sort((a, b) {
        return a[orderBy].compareTo(b[orderBy]);
      });
    } else {
      data.sort((a, b) {
        return b[orderBy].compareTo(a[orderBy]);
      });
    }

    return data;
  }

  List pickValues(Map data) {
    List l = [];

    l.addAll(data["comments"]);
    l.addAll(data["communications"]);
    l.addAll(data["versions"]);

    return l;
  }

  @override
  Widget build(BuildContext context) {
    var events = pickValues(data);
    var sortedEvents = sortByDate(events, "creation", Order.desc);

    return Column(
        mainAxisSize: MainAxisSize.max,
        children: sortedEvents.map<Widget>((event) {
          var eventType;
          if (event["communication_medium"] == "Email") {
            eventType = EventType.email;
          } else if (event["comment_type"] == "Comment") {
            eventType = EventType.comment;
          } else if (event["data"] != null ||
              event["comment_type"] == "Attachment") {
            eventType = EventType.docVersion;
          } else {
            eventType = EventType.docVersion;
          }

          return Column(children: <Widget>[
            Event(eventType, event, callback),
            Container(
              height: 20,
            ),
          ]);
        }).toList());
  }
}
