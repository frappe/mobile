import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/form_view/bottom_sheets/assignees/assignees_bottom_sheet_view.dart';
import 'package:frappe_app/views/form_view/bottom_sheets/attachments/view_attachments_bottom_sheet_view.dart';
import 'package:frappe_app/views/form_view/bottom_sheets/reviews/view_reviews_bottom_sheet_view.dart';
import 'package:frappe_app/views/form_view/bottom_sheets/share/share_bottom_sheet_view.dart';
import 'package:frappe_app/views/form_view/bottom_sheets/tags/tags_bottom_sheet_view.dart';
import 'package:frappe_app/widgets/collapsed_reviews.dart';

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
    return Builder(
      builder: (context) {
        List reviews = docInfo["energy_point_logs"].where((item) {
          return ["Appreciation", "Criticism"].contains(item["type"]);
        }).toList();
        List tags =
            docInfo["tags"].isNotEmpty ? docInfo["tags"].split(',') : [];
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
                filledWidget: docInfo["assignments"].isNotEmpty
                    ? CollapsedAvatars(docInfo["assignments"])
                    : null,
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
                filledWidget: docInfo["attachments"].isNotEmpty
                    ? Text(
                        '${docInfo["attachments"].length} Attachments',
                        style: TextStyle(
                          fontSize: 13,
                          color: FrappePalette.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    : null,
                actionIcon: FrappeIcons.attachment,
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
              if (docInfo["energy_point_logs"] != null)
                DocInfoItem(
                  title: 'Reviews',
                  actionTitle: 'Add review',
                  filledWidget: reviews.isNotEmpty
                      ? CollapsedReviews(
                          reviews,
                        )
                      : null,
                  actionIcon: FrappeIcons.review,
                  onTap: () async {
                    bool refresh = await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => ViewReviewsBottomSheetView(
                            reviews: reviews,
                          ),
                        ) ??
                        false;

                    if (refresh) {
                      refreshCallback();
                    }
                  },
                ),
              DocInfoItem(
                title: 'Tags',
                actionTitle: 'Add tags',
                actionIcon: FrappeIcons.tag,
                filledWidget: tags.isNotEmpty
                    ? Text(
                        '${tags.length} Tags',
                        style: TextStyle(
                          fontSize: 13,
                          color: FrappePalette.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    : null,
                onTap: () async {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => TagsBottomSheetView(
                      tags: tags,
                      doctype: doctype,
                      name: name,
                      refreshCallback: refreshCallback,
                    ),
                  );
                },
              ),
              DocInfoItem(
                title: 'Shared',
                actionTitle: 'Shared with',
                filledWidget: docInfo["shared"].isNotEmpty
                    ? CollapsedAvatars(docInfo["shared"])
                    : null,
                showBorder: false,
                actionIcon: FrappeIcons.share,
                onTap: () async {
                  bool refresh = await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => ShareBottomSheetView(
                          shares: docInfo["shared"],
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
            ],
          ),
        );
      },
    );
  }
}

class DocInfoItem extends StatelessWidget {
  final String title;
  final String actionTitle;
  final String actionIcon;
  final Function onTap;
  final bool showBorder;
  final Widget filledWidget;

  const DocInfoItem({
    Key key,
    @required this.title,
    @required this.actionTitle,
    @required this.actionIcon,
    @required this.onTap,
    this.filledWidget,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          filledWidget ??
              Row(
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
