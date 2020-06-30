import 'package:flutter/material.dart';

import '../widgets/assignees.dart';
import '../widgets/attachments.dart';

class ViewDocInfo extends StatelessWidget {
  final Map docInfo;
  final String doctype;
  final String name;
  final int pageIndex;
  final Function callback;

  ViewDocInfo({
    @required this.doctype,
    @required this.name,
    @required this.docInfo,
    this.callback,
    this.pageIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: pageIndex,
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Text('Attachments'),
              ),
              Tab(
                icon: Text('Assignees'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Attachments(
              doctype: doctype,
              name: name,
              docInfo: docInfo,
              callback: callback,
            ),
            Assignees(
              doctype: doctype,
              name: name,
              assignments: docInfo["assignments"],
              callback: callback,
            ),
          ],
        ),
      ),
    );
  }
}
