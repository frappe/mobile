import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:notus/convert.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:support_app/utils/helpers.dart';
import 'package:support_app/utils/http.dart';
import 'package:zefyr/zefyr.dart';

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

  const Communication({this.communication, this.refDoctype, this.refName});

  @override
  _CommunicationState createState() => _CommunicationState();
}

class _CommunicationState extends State<Communication> {
  var emails;
  var comments;

  @override
  void initState() {
    super.initState();
    emails = widget.communication["communications"]
        .where((c) => c["communication_medium"] == 'Email')
        .toList();
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
      bottomNavigationBar: Container(
        height: 55.0,
        child: BottomAppBar(
          color: Color.fromRGBO(58, 66, 86, 1.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton(
                textColor: Colors.white,
                child: Text('Send Email'), onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return EmailForm(doctype: widget.refDoctype, doc: widget.refName,);
                  }));
              }),
            ],
          ),
        ),
      ),
      body: Column(children: <Widget>[
        Container(
          padding: EdgeInsets.only(bottom: 15),
          child: Text(
            "Email",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: emails.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(emails[index]["subject"]));
              }),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 15),
          child: Text(
            "Comments",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return ListTile(title: Html(data: comments[index]["content"]));
              }),
        ),
      ]),
    );
  }
}

class EditorPage extends StatefulWidget {
  @override
  EditorPageState createState() => EditorPageState();
}

class EditorPageState extends State<EditorPage> {
  /// Allows to control the editor and the document.
  ZefyrController _controller;

  /// Zefyr editor like any other input field requires a focus node.
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    // Here we must load the document and pass it to Zefyr controller.
    final document = _loadDocument();
    _controller = ZefyrController(document);
    _focusNode = FocusNode();
  }

  void _saveDocument(BuildContext context) {
    Delta _delta = _controller.document.toDelta();
    String html =
        markdown.markdownToHtml(notusMarkdown.encode(_delta).toString());
    print(html);
  }

  @override
  Widget build(BuildContext context) {
    // Note that the editor requires special `ZefyrScaffold` widget to be
    // one of its parents.
    return Scaffold(
      appBar: AppBar(
        title: Text("Editor page"),
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.save),
              onPressed: () => _saveDocument(context),
            ),
          )
        ],
      ),
      body: ZefyrScaffold(
        child: ZefyrEditor(
          padding: EdgeInsets.all(16),
          controller: _controller,
          focusNode: _focusNode,
        ),
      ),
    );
  }

  /// Loads the document to be edited in Zefyr.
  NotusDocument _loadDocument() {
    // For simplicity we hardcode a simple document with one line of text
    // saying "Zefyr Quick Start".
    // (Note that delta must always end with newline.)
    final Delta delta = Delta()..insert("\n");
    return NotusDocument.fromDelta(delta);
  }
}

showAlertDialog(BuildContext context) {
  // show the dialog
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[],
        );
      });
}

Map dummyData = {
  "doctype": "communication",
  "fields": [
    {"fieldname": "recipients", "fieldtype": "MultiSelect", "label": "To"},
    // {
    //   "collapsible": 1,
    //   "fieldtype": "Section Break",
    //   "label": "CC, BCC & EMAIL TEMPLATE",
    // },
    {"fieldname": "cc", "fieldtype": "MultiSelect", "label": "CC"},
    {"fieldname": "bcc", "fieldtype": "MultiSelect", "label": "BCC"},
    {
      "hint": "Email Template",
      "fieldname": "email_template",
      "doctype": "Email Template",
      "fieldtype": "Link"
    },
    // {
    //   "fieldtype": "Section Break",
    // },
    {
      "fieldname": "subject",
      "fieldtype": "Small Text",
      "hint": "Subject",
      "controller": TextEditingController()
    },
    {
      "fieldname": "send_me_a_copy",
      "fieldtype": "Check",
      "val": false,
      "hint": "Send Me A Copy"
    },
    {
      "fieldname": "send_read_receipt",
      "fieldtype": "Check",
      "val": false,
      "hint": "Send Read Receipt"
    },
    {
      "fieldname": "attach_document_print",
      "fieldtype": "Check",
      "val": false,
      "hint": "Attach Document Print"
    },
    {
      "fieldtype": "Small Text",
      "fieldname": "content",
      "hint": "content",
      "controller": TextEditingController()
    },
    // {"label":"Select Attachments", 
    // "fieldtype":"HTML",
		// 			"fieldname":"select_attachments"}
  ]
};

class EmailForm extends StatefulWidget {
  final Map wireframe;
  final String doctype;
  final String doc;

  EmailForm({this.wireframe, this.doctype, this.doc});

  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  Map emailObj = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Title"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          var subjectTxt = emailObj["subject"].text;
          var contentTxt = emailObj["content"].text;
          // print(txt);
          print(emailObj);
          sendEmail(
              recipients: emailObj["to"],
              subject: subjectTxt,
              content: contentTxt,
              doctype: widget.doctype,
              doctypeName: widget.doc);
        },
        child: Icon(
          Icons.send,
          color: Colors.blueGrey,
          size: 50,
        ),
      ),
      body: Column(children: <Widget>[
        Container(
          padding: EdgeInsets.only(bottom: 15),
          child: Text(
            "PlaceHolder",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Expanded(
            child: GridView.count(
                padding: EdgeInsets.all(10),
                childAspectRatio: 2.0,
                crossAxisCount: 2,
                children: dummyData["fields"].map<Widget>((field) {
                  if (field["fieldtype"] == 'Small Text') {
                    emailObj[field["fieldname"]] = field["controller"];
                  }

                  return GridTile(
                    // header: Text(grid["header"]),
                    child: generateChildWidget(field, field["val"], (item) {
                      emailObj[field["fieldname"]] = item;
                      setState(() {
                        field["val"] = item;
                      });
                    }),
                  );
                }).toList()))
      ]),
    );
  }
}
