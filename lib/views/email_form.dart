import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/datamodels/doctype_response.dart';

import '../app/locator.dart';

import '../services/api/api.dart';
import '../services/navigation_service.dart';

import '../utils/enums.dart';
import '../utils/helpers.dart';

class EmailForm extends StatefulWidget {
  final String doctype;
  final String doc;
  final String subjectField;
  final String senderField;
  final Function callback;

  EmailForm(
      {@required this.doctype,
      @required this.doc,
      this.subjectField,
      this.senderField,
      @required this.callback});

  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  DoctypeDoc meta;

  @override
  void initState() {
    super.initState();
    meta = DoctypeDoc(
      doctype: "communication",
      fields: [
        DoctypeField(
          fieldname: "recipients",
          fieldtype: "MultiSelect",
          label: "To",
          defaultValue: widget.senderField,
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
          defaultValue:
              '${widget.doctype}: ${widget.subjectField} (${widget.doc})',
        ),
        DoctypeField(
          fieldtype: "Text Editor",
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Send Email'),
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              if (_fbKey.currentState.saveAndValidate()) {
                var formValue = _fbKey.currentState.value;

                await locator<Api>().sendEmail(
                  recipients: formValue["recipients"],
                  subject: formValue["subject"],
                  content: formValue["content"],
                  doctype: widget.doctype,
                  doctypeName: widget.doc,
                );
                widget.callback();
                locator<NavigationService>().pop();
              }
            },
            child: Text('Send'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: FormBuilder(
          key: _fbKey,
          child: ListView(
            children: generateLayout(
                fields: meta.fields,
                viewType: ViewType.newForm,
                withLabel: false),
          ),
        ),
      ),
    );
  }
}
