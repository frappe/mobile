import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/form/controls/check.dart';
import 'package:frappe_app/form/controls/control.dart';
import 'package:frappe_app/form/controls/data.dart';
import 'package:frappe_app/form/controls/multi_select.dart';
import 'package:frappe_app/form/controls/text_editor.dart';
import 'package:frappe_app/model/get_doc_response.dart';
import 'package:frappe_app/model/upload_file_response.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/send_email/bottom_sheets/attachment_bottom_sheet.dart';
import 'package:frappe_app/views/send_email/send_email_viewmodel.dart';
import 'package:frappe_app/widgets/frappe_bottom_sheet.dart';

import '../../app/locator.dart';
import '../../model/doctype_response.dart';

import '../../services/api/api.dart';
import '../base_view.dart';
import '../form_view/bottom_sheets/attachments/view_attachments_bottom_sheet_view.dart';
import 'bottom_sheets/existing_attachments_bottom_sheet.dart';

class SendEmailView extends StatefulWidget {
  final String doctype;
  final String name;
  final String? subjectField;
  final Function callback;
  final String? body;
  final String? to;
  final String? cc;
  final String? bcc;

  SendEmailView({
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
  _SendEmailViewState createState() => _SendEmailViewState();
}

class _SendEmailViewState extends State<SendEmailView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return BaseView<SendEmailViewModel>(
      onModelReady: (model) {
        model.initFields(
          doctype: widget.doctype,
          name: widget.name,
          to: widget.to,
          cc: widget.cc,
          bcc: widget.bcc,
          body: widget.body,
          subjectField: widget.subjectField,
        );
        if (widget.bcc != null || widget.cc != null) {
          model.expanded = true;
        }
      },
      onModelClose: (model) {
        model.expanded = false;
        model.filesToAttach.clear();
      },
      builder: (context, model, child) => FractionallySizedBox(
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
                    onPressed: () async {
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) {
                          return AttachmentBottomSheet(
                              onAddAttachments: () async {
                            List<UploadedFile>? uploadedFiles =
                                await showModalBottomSheet(
                              context: context,
                              useRootNavigator: true,
                              isScrollControlled: true,
                              builder: (context) =>
                                  ViewAttachmentsBottomSheetView(
                                attachments: [],
                                name: widget.name,
                                doctype: widget.doctype,
                              ),
                            );

                            if (uploadedFiles != null) {
                              var uploadedAttachments = uploadedFiles
                                  .map(
                                    (uploadedFile) => Attachments(
                                      name: uploadedFile.name,
                                      fileName: uploadedFile.fileName,
                                      fileUrl: uploadedFile.fileUrl,
                                      isPrivate: uploadedFile.isPrivate,
                                    ),
                                  )
                                  .toList();
                              model.addAttachments(uploadedAttachments);
                              Navigator.of(context).pop();
                            }
                          }, onSelectAttachments: () async {
                            List<Attachments>? filesToAttach =
                                await showModalBottomSheet(
                              context: context,
                              useRootNavigator: true,
                              isScrollControlled: true,
                              builder: (context) =>
                                  ExistingAttachmentsBottomSheet(
                                doctype: widget.doctype,
                                name: widget.name,
                              ),
                            );

                            if (filesToAttach != null) {
                              model.addAttachments(filesToAttach);
                              Navigator.of(context).pop();
                            }
                          });
                        },
                      );
                    },
                    icon: FrappeIcon(
                      FrappeIcons.attachment,
                      size: 26,
                      color: FrappePalette.grey[600],
                    ),
                  ),
                  // IconButton(
                  //   onPressed: () {},
                  //   icon: FrappeIcon(
                  //     FrappeIcons.text_options,
                  //     size: 50,
                  //     color: FrappePalette.grey[600],
                  //   ),
                  // ),
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
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  bottom: 18,
                                ),
                                child: Check(
                                  doctypeField: model.fields[5],
                                  doc: {
                                    model.fields[5].fieldname:
                                        model.sendSettings[
                                            model.fields[5].fieldname],
                                  },
                                  onControlChanged: (val) {
                                    model.updateSendSetting(
                                      fieldname: val.field.fieldname,
                                      value: val.value,
                                    );
                                  },
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  bottom: 18,
                                ),
                                child: Check(
                                  doctypeField: model.fields[6],
                                  doc: {
                                    model.fields[6].fieldname:
                                        model.sendSettings[
                                            model.fields[6].fieldname],
                                  },
                                  onControlChanged: (
                                    val,
                                  ) {
                                    model.updateSendSetting(
                                      fieldname: val.field.fieldname,
                                      value: val.value,
                                    );
                                  },
                                ),
                              ),

                              // Padding(
                              //   padding: const EdgeInsets.only(left: 16.0),
                              //   child: Check(
                              //       doctypeField: model.fields[7],
                              //       doc: {
                              //         model.fields[7].fieldname:
                              //             model.sendSettings[
                              //                 model.fields[7].fieldname],
                              //       },
                              //       onControlChanged: (val) {
                              //         model.updateSendSetting(
                              //           fieldname: val.field.fieldname,
                              //           value: val.value,
                              //         );
                              //       },
                              //     ),
                              //   ),
                            ],
                          );
                        },
                      );
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
                                sendMeACopy: model
                                    .sendSettings[model.fields[5].fieldname],
                                readReceipt: model
                                    .sendSettings[model.fields[6].fieldname],
                                recipients: formValue["recipients"],
                                subject: formValue["subject"],
                                content: formValue["content"],
                                doctype: widget.doctype,
                                doctypeName: widget.name,
                                attachments: model.filesToAttach
                                    .map((fileToAttach) => fileToAttach.name)
                                    .toList());
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
                            doctypeField: model.fields[0],
                            prefixIcon: Text(
                              "${model.fields[0].label!}:",
                              style: TextStyle(
                                color: FrappePalette.grey[500],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            doc: {
                              model.fields[0].fieldname:
                                  model.fields[0].defaultValue,
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            model.toggleExpanded();
                          },
                          icon: FrappeIcon(
                            model.expanded
                                ? FrappeIcons.up_arrow
                                : FrappeIcons.down_arrow,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: model.expanded,
                      child: Column(
                        children: [
                          Divider(
                            thickness: 1,
                            color: FrappePalette.grey[200],
                          ),
                          MultiSelect(
                            doctypeField: model.fields[1],
                            color: Colors.white,
                            chipColor: FrappePalette.grey[100],
                            doc: {
                              model.fields[1].fieldname:
                                  model.fields[1].defaultValue,
                            },
                            prefixIcon: Text(
                              "${model.fields[1].label!}:",
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
                            doctypeField: model.fields[2],
                            color: Colors.white,
                            doc: {
                              model.fields[2].fieldname:
                                  model.fields[2].defaultValue,
                            },
                            prefixIcon: Text(
                              "${model.fields[2].label!}:",
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
                      doctypeField: model.fields[3],
                      color: Colors.white,
                      prefixIcon: Text(
                        "${model.fields[3].label!}:",
                        style: TextStyle(
                          color: FrappePalette.grey[500],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      doc: {
                        model.fields[3].fieldname: model.fields[3].defaultValue,
                      },
                    ),
                    Divider(
                      thickness: 1,
                      color: FrappePalette.grey[200],
                    ),
                    ...model.filesToAttach
                        .asMap()
                        .entries
                        .map((entry) => Attachment(
                              attachment: entry.value,
                              onRemove: () {
                                model.removeAttachment(entry.key);
                              },
                            ))
                        .toList(),
                    TextEditor(
                      doctypeField: model.fields[4],
                      fullHeight: true,
                      color: Colors.white,
                      doc: {
                        model.fields[4].fieldname: model.fields[4].defaultValue,
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Attachment extends StatelessWidget {
  final Attachments attachment;
  final void Function() onRemove;

  Attachment({
    required this.attachment,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Row(
            children: [
              FrappeIcon(
                FrappeIcons.small_file,
                size: 20,
              ),
              SizedBox(
                width: 12,
              ),
              Text(attachment.fileName)
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onRemove,
                child: FrappeIcon(
                  FrappeIcons.close_alt,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
        Divider(
          thickness: 1,
          color: FrappePalette.grey[200],
        ),
      ],
    );
  }
}
