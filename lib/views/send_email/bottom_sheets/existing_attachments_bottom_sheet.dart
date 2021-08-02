import 'package:flutter/material.dart';
import 'package:frappe_app/app/locator.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/model/get_doc_response.dart';
import 'package:frappe_app/services/api/api.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/send_email/send_email_view.dart';
import 'package:frappe_app/widgets/frappe_bottom_sheet.dart';

class ExistingAttachmentsBottomSheet extends StatefulWidget {
  final String doctype;
  final String name;

  const ExistingAttachmentsBottomSheet({
    required this.doctype,
    required this.name,
  });

  @override
  _ExistingAttachmentsBottomSheetState createState() =>
      _ExistingAttachmentsBottomSheetState();
}

class _ExistingAttachmentsBottomSheetState
    extends State<ExistingAttachmentsBottomSheet> {
  List<String> selectedFileNames = [];
  List<Attachments> attachments = [];

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.92,
      child: FrappeBottomSheet(
        title: "Email Attachments",
        onActionButtonPress: () {
          var selectedFiles = attachments
              .where((attachment) =>
                  selectedFileNames.indexOf(attachment.name) != -1)
              .toList();
          Navigator.of(context).pop(selectedFiles);
        },
        trailing: Text('Done'),
        body: FutureBuilder(
          future: locator<Api>().getDocinfo(widget.doctype, widget.name),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              attachments = (snapshot.data as Docinfo).attachments;
              return ListView.builder(
                  itemCount: attachments.length,
                  itemBuilder: (context, index) {
                    var selectedIdx =
                        selectedFileNames.indexOf(attachments[index].name);
                    var isSelected = selectedIdx != -1;
                    return Column(
                      children: [
                        ListTile(
                          onTap: () {
                            if (isSelected) {
                              selectedFileNames.removeAt(selectedIdx);
                            } else {
                              selectedFileNames.add(attachments[index].name);
                            }
                            setState(() {});
                          },
                          trailing: isSelected
                              ? FrappeIcon(
                                  FrappeIcons.tick,
                                )
                              : null,
                          visualDensity: VisualDensity(
                            horizontal: 0,
                            vertical: -4,
                          ),
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
                              Text(
                                attachments[index].fileName,
                              )
                            ],
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          color: FrappePalette.grey[200],
                        ),
                      ],
                    );
                  });
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
