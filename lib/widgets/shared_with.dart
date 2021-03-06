import 'package:flutter/material.dart';

import '../app/locator.dart';
import '../app/router.gr.dart';

import '../services/api/api.dart';
import '../services/navigation_service.dart';

import '../config/frappe_icons.dart';
import '../config/palette.dart';

import '../utils/helpers.dart';
import '../utils/enums.dart';

import '../widgets/frappe_button.dart';
import '../widgets/card_list_tile.dart';
import '../widgets/user_avatar.dart';

class SharedWith extends StatefulWidget {
  final String doctype;
  final String name;
  final Map docInfo;
  final Function callback;

  SharedWith({
    @required this.doctype,
    @required this.name,
    @required this.docInfo,
    this.callback,
  });

  @override
  _SharedWithState createState() => _SharedWithState();
}

class _SharedWithState extends State<SharedWith> {
  Future _futureVal;
  var docInfo;

  @override
  void initState() {
    super.initState();

    _futureVal = Future.value({
      "docinfo": widget.docInfo,
    });
  }

  void _refresh() {
    setState(() {
      _futureVal = locator<Api>().getDocinfo(widget.doctype, widget.name);
    });
  }

  List<Widget> _generateChildren(List l) {
    var children = l.map<Widget>((share) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: 8,
        ),
        child: CardListTile(
          onTap: () async {
            var nav = await locator<NavigationService>().navigateTo(
              Routes.share,
              arguments: ShareArguments(
                docInfo: docInfo,
                doctype: widget.doctype,
                name: widget.name,
              ),
            );

            if (nav == true) {
              _refresh();
              widget.callback();
            }
          },
          color: Palette.fieldBgColor,
          leading: share["user"] != null
              ? UserAvatar(uid: share["user"])
              : UserAvatar(uid: "Everyone"),
          title: Text(
            share["user"] ?? "Everyone",
          ),
        ),
      );
    }).toList();

    children.add(
      Align(
        alignment: Alignment.centerLeft,
        child: FrappeIconButton(
          buttonType: ButtonType.secondary,
          onPressed: () async {
            var nav = await locator<NavigationService>().navigateTo(
              Routes.share,
              arguments: ShareArguments(
                docInfo: docInfo,
                doctype: widget.doctype,
                name: widget.name,
              ),
            );

            if (nav == true) {
              _refresh();
              widget.callback();
            }
          },
          icon: FrappeIcons.small_add,
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
          docInfo = snapshot.data["docinfo"];
          return Column(
            children: _generateChildren(docInfo["shared"]),
          );
        } else if (snapshot.hasError) {
          return handleError(snapshot.error);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
