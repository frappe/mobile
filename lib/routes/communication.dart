import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:support_app/utils/helpers.dart';
import 'package:support_app/utils/http.dart';

sendEmail(
    {@required recipients,
    cc,
    bcc,
    @required subject,
    @required content,
    @required doctype,
    @required doctypeName,
    sendEmail,
    printHtml,
    sendMeACopy,
    printFormat,
    emailTemplate,
    attachments,
    readReceipt,
    printLetterhead}) async {
  var queryParams = {
    'recipients': recipients,
    'subject': subject,
    'content': content,
    'doctype': doctype,
    'name': doctypeName
  };

  final response2 = await dio.post(
      '/method/frappe.core.doctype.communication.email.make',
      data: queryParams,
      options: Options(contentType: Headers.formUrlEncodedContentType));
  if (response2.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    // return DioResponse.fromJson(response2.data);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

postComment(refDocType, refName, content, email) async {
  var queryParams = {
    'reference_doctype': refDocType,
    'reference_name': refName,
    'content': content,
    'comment_email': email,
  };

  final response2 = await dio.post('/method/frappe.desk.form.utils.add_comment',
      data: queryParams,
      options: Options(contentType: Headers.formUrlEncodedContentType));
  if (response2.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    // return DioResponse.fromJson(response2.data);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Communication extends StatefulWidget {
  final Map communication;
  final String refName;
  final String refDoctype;

  const Communication({this.communication, this.refDoctype,
    this.refName});

  @override
  _CommunicationState createState() => _CommunicationState();
}

class _CommunicationState extends State<Communication> {
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
        title: Text('${widget.refDoctype} Communication'),
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
