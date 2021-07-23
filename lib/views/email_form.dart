import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/form/controls/control.dart';
import 'package:frappe_app/form/controls/data.dart';
import 'package:frappe_app/form/controls/multi_select.dart';
import 'package:frappe_app/form/controls/text_editor.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/widgets/frappe_bottom_sheet.dart';

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
        reqd: 1,
        defaultValue: '${widget.subjectField} (#${widget.name})',
      ),
      DoctypeField(
        fieldtype: "Text Editor",
        fieldname: "content",
        label: "Message",
        reqd: 1,
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
    return FractionallySizedBox(
      heightFactor: 0.92,
      child: FrappeBottomSheet(
        title: "New Email",
        bottomBar: Transform.translate(
          offset: Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: FrappeIcon(
                    FrappeIcons.attachment,
                    size: 26,
                    color: FrappePalette.grey[600],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: FrappeIcon(
                    FrappeIcons.text_options,
                    size: 50,
                    color: FrappePalette.grey[600],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: makeControl(
                                  field: fields[5],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: makeControl(
                                  field: fields[6],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: makeControl(
                                  field: fields[7],
                                ),
                              ),
                            ],
                          );
                        });
                  },
                  icon: FrappeIcon(
                    FrappeIcons.send_settings,
                    size: 50,
                    color: FrappePalette.grey[600],
                  ),
                ),
                Spacer(),
                CircleAvatar(
                  backgroundColor: FrappePalette.blue,
                  child: IconButton(
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
                    icon: FrappeIcon(
                      FrappeIcons.send_filled,
                      size: 22,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
        ),
        body: Scaffold(
          backgroundColor: Colors.white,
          body: FormBuilder(
            key: _fbKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: MultiSelect(
                          color: Colors.white,
                          chipColor: FrappePalette.grey[100],
                          doctypeField: fields[0],
                          prefixIcon: Text(
                            "${fields[0].label!}:",
                            style: TextStyle(
                              color: FrappePalette.grey[500],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          doc: {
                            fields[0].fieldname: fields[0].defaultValue,
                          },
                        ),
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
                    child: Column(
                      children: [
                        Divider(
                          thickness: 1,
                          color: FrappePalette.grey[200],
                        ),
                        MultiSelect(
                          doctypeField: fields[1],
                          color: Colors.white,
                          chipColor: FrappePalette.grey[100],
                          doc: {
                            fields[1].fieldname: fields[1].defaultValue,
                          },
                          prefixIcon: Text(
                            "${fields[1].label!}:",
                            style: TextStyle(
                              color: FrappePalette.grey[500],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          color: FrappePalette.grey[200],
                        ),
                        MultiSelect(
                          doctypeField: fields[2],
                          color: Colors.white,
                          doc: {
                            fields[2].fieldname: fields[2].defaultValue,
                          },
                          prefixIcon: Text(
                            "${fields[2].label!}:",
                            style: TextStyle(
                              color: FrappePalette.grey[500],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    color: FrappePalette.grey[200],
                  ),
                  Data(
                    doctypeField: fields[3],
                    color: Colors.white,
                    prefixIcon: Text(
                      "${fields[3].label!}:",
                      style: TextStyle(
                        color: FrappePalette.grey[500],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    doc: {
                      fields[3].fieldname: fields[3].defaultValue,
                    },
                  ),
                  Divider(
                    thickness: 1,
                    color: FrappePalette.grey[200],
                  ),
                  TextEditor(
                    doctypeField: fields[4],
                    fullHeight: true,
                    color: Colors.white,
                    doc: {
                      fields[4].fieldname: fields[4].defaultValue,
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
