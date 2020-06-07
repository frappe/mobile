import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/utils/response_models.dart';
import 'package:frappe_app/utils/rest_apis.dart';

class LinkField2 extends StatefulWidget {
  final String hint;
  final String value;
  final String attribute;
  final String doctype;
  final String refDoctype;
  final String txt;

  final Function callback;

  LinkField2({
    this.txt,
    @required this.attribute,
    @required this.hint,
    @required this.value,
    @required this.callback,
    @required this.doctype,
    @required this.refDoctype,
  });

  @override
  _LinkField2State createState() => _LinkField2State();
}

class _LinkField2State extends State<LinkField2> {
  Future<List> _fetchLinkField(doctype, refDoctype, txt) async {
    var queryParams = {
      'txt': txt,
      'doctype': doctype,
      'reference_doctype': refDoctype,
      'ignore_user_permissions': 0
    };

    var val = await searchLink(queryParams);
    return val.values;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.hint.toUpperCase(),
            style: Palette.labelStyle,
          ),
          FormBuilderTypeAhead(
            decoration: InputDecoration(
                filled: true,
                fillColor: Palette.fieldBgColor,
                enabledBorder: InputBorder.none),
            selectionToTextTransformer: (item) {
              if (item is LinkFieldResponse) {
                return item.value;
              } else {
                return item;
              }
            },
            attribute: widget.attribute,
            itemBuilder: (context, item) {
              return ListTile(
                title: Text(item.value),
              );
            },
            onChanged: (item) {
              widget.callback(item.value);
            },
            initialValue: widget.value,
            suggestionsCallback: (query) {
              var lowercaseQuery = query.toLowerCase();
              return _fetchLinkField(
                  widget.doctype, widget.refDoctype, lowercaseQuery);
            },
          )
        ],
      ),
    );
  }
}
