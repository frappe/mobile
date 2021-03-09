import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/form_view/bottom_sheets/assignees/assignees_bottom_sheet_view.dart';
import 'package:frappe_app/views/form_view/bottom_sheets/attachments/add_attachments_bottom_sheet_view.dart';
import 'package:frappe_app/views/form_view/bottom_sheets/attachments/view_attachments_bottom_sheet_view.dart';

import 'collapsed_avatars.dart';

class DocInfo extends StatelessWidget {
  final Map docInfo;
  final String doctype;
  final String name;
  final Function refreshCallback;

  const DocInfo({
    @required this.docInfo,
    @required this.refreshCallback,
    @required this.doctype,
    @required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FrappePalette.grey[50],
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DocInfoItem(
            title: 'Assignees',
            actionTitle: 'Add assignee',
            actionIcon: FrappeIcons.add_user,
            docInfoItemType: DocInfoItemType.assignees,
            data: docInfo["assignments"],
            onTap: () async {
              bool refresh = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => AssigneesBottomSheetView(
                      assignees: docInfo["assignments"],
                      doctype: doctype,
                      name: name,
                    ),
                  ) ??
                  false;

              if (refresh) {
                refreshCallback();
              }
            },
          ),
          DocInfoItem(
            title: 'Attachments',
            actionTitle: 'Attach file',
            docInfoItemType: DocInfoItemType.attachments,
            actionIcon: FrappeIcons.attachment,
            data: docInfo["attachments"],
            onTap: () async {
              bool refresh = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => ViewAttachmentsBottomSheetView(
                      attachments: docInfo["attachments"],
                    ),
                  ) ??
                  false;

              if (refresh) {
                refreshCallback();
              }
            },
          ),
          // DocInfoItem(
          //   title: 'Reviews',
          //   actionTitle: 'Add review',
          //   docInfoItemType: DocInfoItemType.reviews,
          //   actionIcon: FrappeIcons.review,
          //   onTap: () {},
          // ),
          // DocInfoItem(
          //   title: 'Tags',
          //   actionTitle: 'Add tags',
          //   docInfoItemType: DocInfoItemType.tags,
          //   actionIcon: FrappeIcons.tag,
          //   onTap: () {},
          // ),
          // DocInfoItem(
          //   title: 'Shared',
          //   actionTitle: 'Shared with',
          //   docInfoItemType: DocInfoItemType.shared,
          //   showBorder: false,
          //   actionIcon: FrappeIcons.share,
          //   onTap: () {},
          // ),
        ],
      ),
    );
  }
}

class DocInfoItem extends StatelessWidget {
  final String title;
  final String actionTitle;
  final String actionIcon;
  final Function onTap;
  final bool showBorder;
  final DocInfoItemType docInfoItemType;
  final List data;

  const DocInfoItem({
    Key key,
    @required this.title,
    @required this.actionTitle,
    @required this.actionIcon,
    @required this.onTap,
    @required this.docInfoItemType,
    @required this.data,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var filledWidget;
    if (docInfoItemType == DocInfoItemType.assignees) {
      filledWidget = CollapsedAvatars(data);
    } else if (docInfoItemType == DocInfoItemType.attachments) {
      filledWidget = Text(
        '${data.length} Attachments',
        style: TextStyle(
          fontSize: 13,
          color: FrappePalette.grey[600],
          fontWeight: FontWeight.w400,
        ),
      );
    }
    return FlatButton(
      onPressed: onTap,
      shape: showBorder
          ? Border(
              bottom: BorderSide(
                color: FrappePalette.grey[200],
                width: 2,
              ),
            )
          : null,
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: FrappePalette.grey[900],
              fontWeight: FontWeight.w400,
            ),
          ),
          Spacer(),
          data.isNotEmpty
              ? filledWidget
              : Row(
                  children: [
                    FrappeIcon(
                      actionIcon,
                      color: FrappePalette.grey[600],
                      size: 13,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      actionTitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: FrappePalette.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
