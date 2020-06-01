import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../utils/helpers.dart';
import '../utils/http.dart';
import '../widgets/collapsible.dart';

class EmailForm extends StatefulWidget {
  final String doctype;
  final String doc;
  final String subject;
  final String raisedBy;

  EmailForm({
    @required this.doctype,
    @required this.doc,
    this.subject,
    this.raisedBy,
  });

  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  final Map dummyData = {
    "doctype": "communication",
    "fields": [
      {
        "fieldname": "recipients",
        "fieldtype": "MultiSelect",
        "label": "To",
        "reqd": 1
      },
      // {
      //   "collapsible": 1,
      //   "fieldtype": "Section Break",
      //   "label": "CC, BCC & EMAIL TEMPLATE",
      // },
      {
        "fieldname": "cc",
        "fieldtype": "MultiSelect",
        "label": "CC",
      },
      {
        "fieldname": "bcc",
        "fieldtype": "MultiSelect",
        "label": "BCC",
      },
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
            onPressed: () async {
              if (_fbKey.currentState.saveAndValidate()) {
                var formValue = _fbKey.currentState.value;
                
                await _sendEmail(
                    recipients: formValue["recipients"],
                    subject: formValue["subject"],
                    content: formValue["content"],
                    doctype: widget.doctype,
                    doctypeName: widget.doc);
                Navigator.of(context).pop();
              }
            },
            child: Text('Send'),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: FormBuilder(
            key: _fbKey,
            child: Column(
              children: <Widget>[
                // TO
                generateChildWidget(dummyData["fields"][0], widget.raisedBy),
                Divider(
                  thickness: 2.0,
                ),
                // TODO: collapsible
                // Collapsible("CC, BCC", (item) {
                //   emailObj.addAll(item);
                // }),
                // Divider(
                //   thickness: 2.0,
                // ),
                // subject
                generateChildWidget(dummyData["fields"][4], '${widget.doctype}: ${widget.subject} (${widget.doc})'),
                // content
                generateChildWidget(dummyData["fields"][5]),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Row(
                    children: <Widget>[
                      // send_me_a_copy
                      Expanded(
                        child: generateChildWidget(dummyData["fields"][6]),
                      ),
                      // send_read_receipt
                      Expanded(
                        child: generateChildWidget(dummyData["fields"][7]),
                      )
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: generateChildWidget(dummyData["fields"][8]),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
