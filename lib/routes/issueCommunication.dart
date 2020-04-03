import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:support_app/utils/helpers.dart';

class IssueCommunication extends StatefulWidget {
  final Map communication;

  const IssueCommunication(this.communication);

  @override
  _IssueCommunicationState createState() => _IssueCommunicationState();
}

class _IssueCommunicationState extends State<IssueCommunication> {
  var emails;
  var comments;

  @override
  void initState() {
    super.initState();
    emails = widget.communication["communications"].where((c) => c["communication_medium"] == 'Email').toList();
    comments = widget.communication["comments"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              logout(context);
            },
          )
        ],
        title: Text('Issue Communication'),
      ),
      body: Column(children: <Widget>[
        Container(
          padding: EdgeInsets.only(bottom: 15),
          child: Text(
            "Email",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: emails.length,
              itemBuilder: (context, index) {
                return ListTile(
                    title: Text(emails[index]["subject"]));
              }),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 15),
          child: Text(
            "Comments",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return ListTile(
                    title: Html(data: comments[index]["content"]));
              }),
        ),
      ]),
    );
  }
}
