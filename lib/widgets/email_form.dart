import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:support_app/utils/helpers.dart';
import 'package:support_app/utils/http.dart';
import 'package:support_app/widgets/collapsible.dart';

class EmailForm extends StatefulWidget {
  final String doctype;
  final String doc;

  EmailForm({@required this.doctype, @required this.doc});

  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
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
      },
      {
        "fieldtype": "Text Editor",
        "fieldname": "content",
        "hint": "Message",
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
      // {"label":"Select Attachments",
      // "fieldtype":"HTML",
      // 			"fieldname":"select_attachments"}
    ]
  };
  Map emailObj = {};

  _sendEmail(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Email'),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              _sendEmail(
                  recipients: emailObj["recipients"],
                  subject: emailObj["subject"],
                  content: emailObj["content"],
                  doctype: widget.doctype,
                  doctypeName: widget.doc);
            },
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(children: <Widget>[
            generateChildWidget(dummyData["fields"][0], null, (item) {
              emailObj[dummyData["fields"][0]["fieldname"]] = item;
              setState(() {
                dummyData["fields"][0]["val"] = item;
              });
            }),
            Divider(
              thickness: 2.0,
            ),
            Collapsible("CC, BCC", (item) {
              emailObj.addAll(
                item
              );
            }),
            Divider(
              thickness: 2.0,
            ),
            generateChildWidget(
                dummyData["fields"][4], dummyData["fields"][4]["val"], (item) {
              emailObj[dummyData["fields"][4]["fieldname"]] = item;
              setState(() {
                dummyData["fields"][4]["val"] = item;
              });
            }),
            generateChildWidget(
                dummyData["fields"][5], dummyData["fields"][5]["val"], (item) {
              emailObj[dummyData["fields"][5]["fieldname"]] = item;
              setState(() {
                dummyData["fields"][5]["val"] = item;
              });
            }),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: generateChildWidget(
                        dummyData["fields"][8], dummyData["fields"][8]["val"],
                        (item) {
                      emailObj[dummyData["fields"][8]["fieldname"]] = item;
                      setState(() {
                        dummyData["fields"][8]["val"] = item;
                      });
                    }),
                  ),
                  Expanded(
                    child: generateChildWidget(
                        dummyData["fields"][6], dummyData["fields"][6]["val"],
                        (item) {
                      emailObj[dummyData["fields"][6]["fieldname"]] = item;
                      setState(() {
                        dummyData["fields"][6]["val"] = item;
                      });
                    }),
                  )
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: generateChildWidget(
                      dummyData["fields"][7], dummyData["fields"][7]["val"],
                      (item) {
                    emailObj[dummyData["fields"][7]["fieldname"]] = item;
                    setState(() {
                      dummyData["fields"][7]["val"] = item;
                    });
                  }),
                )
              ],
            )
          ]),
        ),
      ),
    );
  }
}
