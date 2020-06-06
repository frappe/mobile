import 'package:flutter/material.dart';
import 'package:frappe_app/config/palette.dart';

import 'like_doc.dart';

class ListItem extends StatelessWidget {
  final String title;
  final String modifiedOn;
  final String name;
  final String doctype;

  final bool isFav;
  final bool seen;

  final int commentCount;

  final List status;
  final List assignee;

  final Function onButtonTap;
  final Function onListTap;

  ListItem({
    @required this.doctype,
    @required this.isFav,
    @required this.seen,
    @required this.commentCount,
    @required this.status,
    @required this.onButtonTap,
    @required this.title,
    @required this.assignee,
    @required this.modifiedOn,
    @required this.name,
    @required this.onListTap,
  });

  Widget _buildStatusButton(List l) {
    return GestureDetector(
      onTap: () => onButtonTap(l[0], l[1]),
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Palette.lightGreen,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          l[1] ?? "",
          style: TextStyle(color: Palette.darkGreen, fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double colWidth = MediaQuery.of(context).size.width * 0.8;

    return GestureDetector(
      onTap: onListTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(modifiedOn, style: Palette.dimTxtStyle),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                    child: Icon(
                      Icons.lens,
                      size: 5,
                      color: Palette.dimTxtColor,
                    ),
                  ),
                  Text(
                    name,
                    style: Palette.dimTxtStyle,
                  ),
                  Spacer(),
                  LikeDoc(
                    doctype: doctype,
                    name: name,
                    isFav: isFav,
                  )
                ],
              ),
              Container(
                width: colWidth,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: !seen ? FontWeight.bold : null,
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  _buildStatusButton(status),
                  VerticalDivider(),
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Icon(
                      Icons.comment,
                      size: 14,
                      color: Palette.dimTxtColor,
                    ),
                  ),
                  Text(
                    '$commentCount',
                    style: Palette.dimTxtStyle,
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: assignee != null
                        ? () {
                            onButtonTap(assignee[0], assignee[1]);
                          }
                        : null,
                    icon: Container(
                      height: 20,
                      width: 20,
                      color: Palette.bgColor,
                      child: Center(
                          child: assignee != null
                              ? Text(
                                  assignee[1][0].toUpperCase(),
                                  textAlign: TextAlign.center,
                                )
                              : Text('')),
                    ),
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
