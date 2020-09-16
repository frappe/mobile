import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/screens/add_review.dart';

import '../config/frappe_icons.dart';
import '../config/palette.dart';
import '../utils/backend_service.dart';
import '../utils/enums.dart';
import '../widgets/frappe_button.dart';
import '../widgets/card_list_tile.dart';

class Reviews extends StatefulWidget {
  final String doctype;
  final String name;
  final Map docInfo;
  final Function callback;
  final Map meta;
  final Map doc;

  Reviews({
    @required this.doctype,
    @required this.name,
    @required this.docInfo,
    @required this.meta,
    @required this.doc,
    this.callback,
  });

  @override
  _ReviewsState createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  Future _futureVal;
  BackendService backendService;

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
    var children = l.map<Widget>((review) {
      var trailingWidget;
      var tooltipMsg;
      if (review["type"] == "Appreciation") {
        trailingWidget = Text(
          "+${review["points"]}",
          style: TextStyle(
            color: FrappePalette.darkGreen,
            fontWeight: FontWeight.bold,
          ),
        );
        tooltipMsg =
            "${review['points']} appreciation points for ${review['user']} for ${review['reason']}";
      } else if (review["type"] == "Criticism") {
        trailingWidget = Text(
          "${review["points"]}",
          style: TextStyle(
            color: FrappePalette.red,
            fontWeight: FontWeight.bold,
          ),
        );
        tooltipMsg =
            "${review['points']} criticism points for ${review['user']} for ${review['reason']}";
      }
      return Tooltip(
        message: tooltipMsg,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: CardListTile(
            color: Palette.fieldBgColor,
            title: Text(review["owner"]),
            trailing: trailingWidget,
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
                  return AddReview(
                    doctype: widget.doctype,
                    docInfo: widget.docInfo,
                    meta: widget.meta,
                    doc: widget.doc,
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
          var docInfo = snapshot.data["docinfo"];
          var reviews = docInfo["energy_point_logs"].where((item) {
            return ["Appreciation", "Criticism"].contains(item["type"]);
          }).toList();
          return Column(
            children: _generateChildren(reviews),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
