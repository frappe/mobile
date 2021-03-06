import 'package:flutter/material.dart';

import '../app/locator.dart';
import '../app/router.gr.dart';

import '../config/frappe_icons.dart';
import '../config/palette.dart';

import '../services/api/api.dart';
import '../services/navigation_service.dart';

import '../utils/enums.dart';
import '../utils/helpers.dart';

import '../widgets/frappe_button.dart';
import '../widgets/card_list_tile.dart';

class Tags extends StatefulWidget {
  final String doctype;
  final String name;
  final Map docInfo;
  final Function callback;

  Tags({
    @required this.doctype,
    @required this.name,
    @required this.docInfo,
    this.callback,
  });

  @override
  _TagsState createState() => _TagsState();
}

class _TagsState extends State<Tags> {
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
      _futureVal = locator<Api>().getDocinfo(widget.doctype, widget.name);
    });
  }

  List<Widget> _generateChildren(List l) {
    var children = l.map<Widget>((tag) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: CardListTile(
          color: Palette.fieldBgColor,
          title: Text("#$tag"),
          trailing: IconButton(
            icon: Icon(Icons.close),
            onPressed: () async {
              await locator<Api>().removeTag(
                widget.doctype,
                widget.name,
                tag,
              );
              _refresh();
              widget.callback();
              showSnackBar('Tag removed', context);
            },
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
              Routes.addTags,
              arguments: AddTagsArguments(
                doctype: widget.doctype,
                name: widget.name,
              ),
            );

            if (nav == true) {
              _refresh();
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
          var docInfo = snapshot.data["docinfo"];
          var tags =
              docInfo["tags"].isNotEmpty ? docInfo["tags"].split(',') : [];
          return Column(
            children: _generateChildren(tags),
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
