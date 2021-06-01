import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';

import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/base_view.dart';

import 'package:frappe_app/widgets/frappe_bottom_sheet.dart';

import 'add_attachments_bottom_sheet_viewmodel.dart';

class AddAttachmentsBottomSheetView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseView<AddAttachmentsBottomSheetViewModel>(
      onModelClose: (model) {},
      builder: (context, model, child) => FractionallySizedBox(
        heightFactor: 0.2,
        child: FrappeBottomSheet(
          title: 'Attachments',
          onActionButtonPress: () {},
          trailing: Row(
            children: [
              FrappeIcon(
                FrappeIcons.small_add,
                color: FrappePalette.blue[500],
                size: 16,
              ),
              Text(
                'Attach File',
                style: TextStyle(
                  color: FrappePalette.blue[500],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          body: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              UploadType(
                iconBackground: FrappePalette.blue,
                subtitle: 'Select File',
                iconPath: FrappeIcons.browse,
              ),
              UploadType(
                iconBackground: FrappePalette.darkGreen,
                subtitle: 'Library',
                iconPath: FrappeIcons.folder_open,
              ),
              UploadType(
                iconBackground: FrappePalette.yellow,
                subtitle: 'Link',
                iconPath: FrappeIcons.link_url,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UploadType extends StatelessWidget {
  final String iconPath;
  final String subtitle;
  final Color iconBackground;

  const UploadType({
    required this.iconPath,
    required this.subtitle,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FrappePalette.grey[100],
        borderRadius: BorderRadius.circular(
          8,
        ),
      ),
      height: 100,
      width: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: iconBackground,
            child: FrappeIcon(
              iconPath,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: FrappePalette.grey[800],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
