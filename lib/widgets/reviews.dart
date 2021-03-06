import 'package:flutter/material.dart';

import '../app/locator.dart';
import '../app/router.gr.dart';

import '../model/doctype_response.dart';

import '../config/frappe_palette.dart';
import '../config/frappe_icons.dart';
import '../config/palette.dart';

import '../utils/enums.dart';
import '../utils/helpers.dart';

import '../services/api/api.dart';
import '../services/navigation_service.dart';

import '../widgets/frappe_button.dart';
import '../widgets/card_list_tile.dart';

class Reviews extends StatefulWidget {
  final String doctype;
  final String name;
  final Map docInfo;
  final Function callback;
  final DoctypeDoc meta;
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
            var nav = await locator<NavigationService>().navigateTo(
              Routes.addReview,
              arguments: AddReviewArguments(
                doctype: widget.doctype,
                docInfo: widget.docInfo,
                meta: widget.meta,
                doc: widget.doc,
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
          var docInfo = snapshot.data["docinfo"];
          var reviews = docInfo["energy_point_logs"].where((item) {
            return ["Appreciation", "Criticism"].contains(item["type"]);
          }).toList();
          return Column(
            children: _generateChildren(reviews),
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
