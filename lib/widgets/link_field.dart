import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/utils/response_models.dart';

import '../utils/rest_apis.dart';

class LinkField extends StatefulWidget {
  final value;
  final hint;
  final Function onSuggestionSelected;

  final doctype;
  final refDoctype;
  final reqType;

  LinkField({
    this.value,
    this.reqType,
    @required this.onSuggestionSelected,
    @required this.hint,
    @required this.doctype,
    @required this.refDoctype,
  });

  @override
  _LinkFieldState createState() => _LinkFieldState();
}

class _LinkFieldState extends State<LinkField> {
  final TextEditingController _typeAheadController = TextEditingController();

  Future _fetchLinkField(doctype, refDoctype, txt) async {
    var queryParams = {
      'txt': txt,
      'doctype': doctype,
      'reference_doctype': refDoctype,
      'ignore_user_permissions': 0
    };

    return searchLink(queryParams);
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
      getImmediateSuggestions: true,
      textFieldConfiguration: TextFieldConfiguration(
        controller: this._typeAheadController..text = widget.value,
        decoration: InputDecoration(
          labelStyle: Palette.labelStyle,
          labelText: widget.hint.toUpperCase(),
          enabledBorder: InputBorder.none,
          // hintText: widget.hint,
        ),
      ),
      suggestionsCallback: (pattern) async {
        var val =
            await _fetchLinkField(widget.doctype, widget.refDoctype, pattern);

        // TODO: find better way for removing value
        var blankVal = DioLinkFieldResponse.fromJson({
          "results": [
            {"value": ''}
          ]
        });
        val.values.insert(0, blankVal.values[0]);
        return val.values;
        // return val.values;
      },
      itemBuilder: (context, item) {
        return ListTile(
          title: Text(item.value),
        );
      },
      onSuggestionSelected: (item) {
        widget.onSuggestionSelected(item.value);
      },
    );
  }
}
