import 'package:flutter/material.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/utils/helpers.dart';

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

  @override
  Widget build(BuildContext context) {
    double colWidth = MediaQuery.of(context).size.width * 0.8;

    return GestureDetector(
      onTap: onListTap,
      child: Card(
        margin: EdgeInsets.zero,
        shape: Border.symmetric(
          vertical: BorderSide(
            width: 0.5,
            color: Palette.borderColor,
          ),
        ),
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.only(left: 18.0, right: 8, bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      name,
                      style: Palette.dimTxtStyle,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                      child: Icon(
                        Icons.lens,
                        size: 5,
                        color: Palette.dimTxtColor,
                      ),
                    ),
                    Text(modifiedOn, style: Palette.dimTxtStyle),
                    Spacer(),
                    LikeDoc(
                      doctype: doctype,
                      name: name,
                      isFav: isFav,
                    )
                  ],
                ),
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
                  GestureDetector(
                    onTap: () => onButtonTap(
                      status[0],
                      status[1],
                    ),
                    child: buildStatusButton(
                      doctype,
                      status[1],
                    ),
                  ),
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
