import 'package:flutter/material.dart';
import 'package:frappe_app/screens/share.dart';
import 'package:frappe_app/widgets/user_avatar.dart';

import '../config/frappe_icons.dart';
import '../config/palette.dart';
import '../utils/backend_service.dart';
import '../utils/enums.dart';
import '../widgets/frappe_button.dart';
import '../widgets/card_list_tile.dart';

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
  BackendService backendService;
  var docInfo;

  @override
  void initState() {
    super.initState();
    backendService = BackendService();

    _futureVal =
        Future.delayed(Duration(seconds: 0), () => {"docinfo": widget.docInfo});
  }

  void _refresh() {
    setState(() {
      _futureVal = backendService.getDocinfo(widget.doctype, widget.name);
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
            var nav = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Share(
                    docInfo: docInfo,
                    doctype: widget.doctype,
                    name: widget.name,
                  );
                },
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
            var nav = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Share(
                    docInfo: docInfo,
                    doctype: widget.doctype,
                    name: widget.name,
                  );
                },
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
          return Text("${snapshot.error}");
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
