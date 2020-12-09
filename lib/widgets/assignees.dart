import 'package:flutter/material.dart';
import 'package:frappe_app/app/locator.dart';
import 'package:frappe_app/app/router.gr.dart';
import 'package:frappe_app/services/navigation_service.dart';

import './frappe_button.dart';

import '../config/palette.dart';
import '../config/frappe_icons.dart';

import '../widgets/user_avatar.dart';
import '../widgets/card_list_tile.dart';

import '../services/backend_service.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';

import '../views/add_assignees.dart';

class Assignees extends StatefulWidget {
  final String doctype;
  final String name;
  final Function callback;
  final Map docInfo;

  Assignees({
    @required this.doctype,
    @required this.name,
    @required this.callback,
    @required this.docInfo,
  });

  @override
  _AssigneesState createState() => _AssigneesState();
}

class _AssigneesState extends State<Assignees> {
  Future _futureVal;

  @override
  void initState() {
    super.initState();
    _futureVal = Future.value({
      "docinfo": widget.docInfo,
    });
  }

  void _refresh() {
    setState(() {
      _futureVal = BackendService.getDocinfo(
        widget.doctype,
        widget.name,
      );
    });
  }

  List<Widget> _generateChildren(List assignments) {
    List<Widget> children = assignments.asMap().entries.map<Widget>(
      (entry) {
        var d = entry.value;
        return Padding(
          padding: EdgeInsets.only(
            bottom: 8,
          ),
          child: CardListTile(
            color: Palette.fieldBgColor,
            leading: UserAvatar(uid: d["owner"]),
            title: Text(
              d["owner"],
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.clear,
              ),
              onPressed: () async {
                await BackendService.removeAssignee(
                  widget.doctype,
                  widget.name,
                  d["owner"],
                );

                showSnackBar('Assignee Removed', context);
                _refresh();
                widget.callback();
              },
            ),
          ),
        );
      },
    ).toList();

    children.add(
      Align(
        alignment: Alignment.centerLeft,
        child: FrappeIconButton.small(
          buttonType: ButtonType.secondary,
          icon: FrappeIcons.small_add,
          onPressed: () async {
            var nav = await locator<NavigationService>().navigateTo(
              Routes.addAssignees,
              arguments: AddAssigneesArguments(
                doctype: widget.doctype,
                name: widget.name,
              ),
            );

            if (nav == true) {
              _refresh();
              widget.callback();
            }
          },
        ),
      ),
    );

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureVal,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var docInfo = snapshot.data["docinfo"];
          return Column(
            children: _generateChildren(docInfo["assignments"]),
          );
        } else if (snapshot.hasError) {
          return handleError(snapshot.error);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
