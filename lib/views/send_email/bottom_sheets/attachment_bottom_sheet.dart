import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/model/upload_file_response.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/form_view/bottom_sheets/attachments/view_attachments_bottom_sheet_view.dart';

import 'existing_attachments_bottom_sheet.dart';

class AttachmentBottomSheet extends StatelessWidget {
  final void Function() onAddAttachments;
  final void Function() onSelectAttachments;

  const AttachmentBottomSheet({
    required this.onAddAttachments,
    required this.onSelectAttachments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        ListTile(
          title: Text('Add Attachments'),
          onTap: onAddAttachments,
          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
          leading: FrappeIcon(
            FrappeIcons.attachment,
          ),
        ),
        ListTile(
          onTap: onSelectAttachments,
          title: Text('Select Attachments'),
          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
          leading: FrappeIcon(
            FrappeIcons.small_file_attach,
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
