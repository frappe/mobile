import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/utils/indicator.dart';
import 'package:frappe_app/widgets/collapsed_avatars.dart';
import 'package:frappe_app/widgets/like_doc.dart';

class ListItem extends StatelessWidget {
  final String? title;
  final String modifiedOn;
  final String name;
  final String doctype;

  final bool isFav;
  final bool seen;

  final int commentCount;
  final int likeCount;

  final List status;
  final List assignee;

  final Function onButtonTap;
  final void Function() onListTap;
  final Function toggleLikeCallback;

  ListItem({
    required this.doctype,
    required this.isFav,
    required this.seen,
    required this.commentCount,
    required this.likeCount,
    required this.status,
    required this.onButtonTap,
    required this.title,
    required this.assignee,
    required this.modifiedOn,
    required this.name,
    required this.onListTap,
    required this.toggleLikeCallback,
  });

  @override
  Widget build(BuildContext context) {
    double colWidth = MediaQuery.of(context).size.width * 0.8;

    return GestureDetector(
      onTap: onListTap,
      child: Card(
        margin: EdgeInsets.zero,
        shape: Border.symmetric(
          vertical: BorderSide(
            width: 0.1,
          ),
        ),
        elevation: 0,
        child: Container(
          height: 112,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Palette.secondaryButtonColor,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: colWidth,
                    child: Text(
                      title ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: FrappePalette.grey[900],
                        fontWeight: !seen ? FontWeight.w600 : null,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      style: TextStyle(
                        color: FrappePalette.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                    child: Icon(
                      Icons.lens,
                      size: 5,
                      color: Palette.secondaryTxtColor,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      modifiedOn,
                      style: TextStyle(
                        color: FrappePalette.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => onButtonTap(
                      status[0],
                      status[1],
                    ),
                    child: Indicator.buildStatusButton(
                      doctype,
                      status[1],
                    ),
                  ),
                  VerticalDivider(),
                  FrappeIcon(
                    FrappeIcons.message_1,
                    size: 16,
                    color: FrappePalette.grey[500],
                  ),
                  SizedBox(
                    width: 6.0,
                  ),
                  Text(
                    '$commentCount',
                    style: TextStyle(
                      color: FrappePalette.grey[700],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  VerticalDivider(),
                  LikeDoc(
                    doctype: doctype,
                    name: name,
                    successCallback: toggleLikeCallback,
                    isFav: isFav,
                    iconColor: FrappePalette.grey[500],
                  ),
                  SizedBox(
                    width: 6.0,
                  ),
                  Text(
                    '$likeCount',
                    style: TextStyle(
                      color: FrappePalette.grey[700],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Spacer(),
                  assignee != null
                      ? CollapsedAvatars(assignee)
                      : Container(
                          height: 38,
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
