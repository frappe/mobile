import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/form/controls/control.dart';
import 'package:frappe_app/utils/frappe_icon.dart';

import '../app/locator.dart';
import '../model/doctype_response.dart';

import '../services/api/api.dart';

class EmailForm extends StatefulWidget {
  final String doctype;
  final String name;
  final String? subjectField;
  final Function callback;
  final String? body;
  final String? to;
  final String? cc;
  final String? bcc;

  EmailForm({
    required this.callback,
    required this.doctype,
    required this.name,
    this.subjectField,
    this.body,
    this.to,
    this.cc,
    this.bcc,
  });

  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  late List<DoctypeField> fields;
  bool expanded = false;

  @override
  void initState() {
    super.initState();

    if (widget.bcc != null || widget.cc != null) {
      expanded = true;
    }

    fields = [
      DoctypeField(
        fieldname: "recipients",
        fieldtype: "MultiSelect",
        label: "To",
        defaultValue: widget.to,
        reqd: 1,
      ),
      DoctypeField(
        fieldname: "cc",
        fieldtype: "MultiSelect",
        label: "CC",
        defaultValue: widget.cc,
      ),
      DoctypeField(
        fieldname: "bcc",
        fieldtype: "MultiSelect",
        label: "BCC",
        defaultValue: widget.bcc,
      ),
      // {
      //   "label": "Email Template",
      //   "fieldname": "email_template",
      //   "doctype": "Email Template",
      //   "fieldtype": "Link"
      // },
      // {
      //   "fieldtype": "Section Break",
      // },
      DoctypeField(
        fieldname: "subject",
        fieldtype: "Small Text",
        label: "Subject",
        defaultValue: '${widget.subjectField} (#${widget.name})',
      ),
      DoctypeField(
        fieldtype: "Text Editor",
        fieldname: "content",
        label: "Message",
        defaultValue: widget.body,
      ),
      DoctypeField(
        fieldname: "send_me_a_copy",
        fieldtype: "Check",
        defaultValue: false,
        label: "Send Me A Copy",
      ),
      DoctypeField(
        fieldname: "send_read_receipt",
        fieldtype: "Check",
        defaultValue: false,
        label: "Send Read Receipt",
      ),
      DoctypeField(
        fieldname: "attach_document_print",
        fieldtype: "Check",
        defaultValue: false,
        label: "Attach Document Print",
      ),
      // {"label":"Select Attachments",
      // "fieldtype":"HTML",
      // 			"fieldname":"select_attachments"}
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.8,
        title: Text('Send Email'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              if (_fbKey.currentState != null) {
                if (_fbKey.currentState!.saveAndValidate()) {
                  var formValue = _fbKey.currentState!.value;

                  await locator<Api>().sendEmail(
                    recipients: formValue["recipients"],
                    subject: formValue["subject"],
                    content: formValue["content"],
                    doctype: widget.doctype,
                    doctypeName: widget.name,
                  );
                  widget.callback();
                  Navigator.of(context).pop();
                }
              }
            },
            child: Text(
              'Send',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
        child: FormBuilder(
          key: _fbKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      child: makeControl(field: fields[0], doc: {
                        fields[0].fieldname: fields[0].defaultValue,
                      }),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          expanded = !expanded;
                        });
                      },
                      icon: FrappeIcon(
                        expanded
                            ? FrappeIcons.up_arrow
                            : FrappeIcons.down_arrow,
                        size: 12,
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: expanded,
                  child: makeControl(field: fields[1], doc: {
                    fields[1].fieldname: fields[1].defaultValue,
                  }),
                ),
                Visibility(
                  visible: expanded,
                  child: makeControl(field: fields[2], doc: {
                    fields[2].fieldname: fields[2].defaultValue,
                  }),
                ),
                makeControl(
                  field: fields[3],
                  doc: {
                    fields[3].fieldname: fields[3].defaultValue,
                  },
                ),
                makeControl(
                  field: fields[4],
                  doc: {
                    fields[4].fieldname: fields[4].defaultValue,
                  },
                ),
                Row(
                  children: [
                    Flexible(
                      child: makeControl(
                        field: fields[5],
                      ),
                    ),
                    Flexible(
                      child: makeControl(
                        field: fields[6],
                      ),
                    ),
                  ],
                ),
                makeControl(
                  field: fields[7],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
