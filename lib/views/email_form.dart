import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/widgets/custom_form.dart';

import '../app/locator.dart';
import '../model/doctype_response.dart';

import '../services/api/api.dart';

import '../utils/helpers.dart';

class EmailForm extends StatelessWidget {
  final String doctype;
  final String doc;
  final String? subjectField;
  final String? senderField;
  final Function callback;

  EmailForm({
    required this.doctype,
    required this.doc,
    this.subjectField,
    this.senderField,
    required this.callback,
  });

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final meta = DoctypeDoc(
      issingle: 1,
      module: "",
      name: "",
      doctype: "communication",
      fields: [
        DoctypeField(
          fieldname: "recipients",
          fieldtype: "MultiSelect",
          label: "To",
          defaultValue: senderField,
          reqd: 1,
        ),

        // {
        //   "collapsible": 1,
        //   "fieldtype": "Section Break",
        //   "label": "CC, BCC & EMAIL TEMPLATE",
        // },
        // {
        //   "fieldname": "cc",
        //   "fieldtype": "MultiSelect",
        //   "label": "CC",
        // },
        // {
        //   "fieldname": "bcc",
        //   "fieldtype": "MultiSelect",
        //   "label": "BCC",
        // },
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
          defaultValue: '$doctype}: $subjectField} ($doc})',
        ),
        DoctypeField(
          fieldtype: "Text Editor2",
          fieldname: "content",
          label: "Message",
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
      ],
    );
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
                    doctype: doctype,
                    doctypeName: doc,
                  );
                  callback();
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
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: CustomForm(
          fields: meta.fields,
          formKey: _fbKey,
          withLabel: false,
        ),
      ),
    );
  }
}
