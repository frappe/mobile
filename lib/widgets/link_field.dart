import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../utils/rest_apis.dart';

Future fetchLinkField(doctype, refDoctype, txt) async {
  var queryParams = {
    'txt': txt,
    'doctype': doctype,
    'reference_doctype': refDoctype,
    'ignore_user_permissions': 0
  };

  return searchLink(queryParams);
}

Future fetchValues(Map data, String reqType) {
  if(reqType == 'get_contact_list') {
    return getContactList(data);
  }
  return searchLink(data);
}

class LinkField extends StatefulWidget {
  final value;
  final hint;
  final Function onSuggestionSelected;

  final doctype;
  final refDoctype;
  final txt;
  final reqType;

  LinkField(
      {this.value,
      this.reqType,
      this.onSuggestionSelected,
      @required this.hint,
      this.doctype,
      this.refDoctype,
      this.txt});

  @override
  _LinkFieldState createState() => _LinkFieldState();
}

class _LinkFieldState extends State<LinkField> {
  // AutoCompleteTextField searchTextField;
  String dropdownVal;
  Future futureVal;
  var queryParams;

  final TextEditingController _typeAheadController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if(widget.reqType == 'get_contact_list') {
      queryParams = {
        'txt': widget.txt
      };
    } else {
      queryParams = {
        'txt': widget.txt,
        'doctype': widget.doctype,
        'reference_doctype': widget.refDoctype,
        'ignore_user_permissions': 0
      };
    }
    futureVal = fetchValues(queryParams, widget.reqType);
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: this._typeAheadController..text = widget.value,
        decoration: InputDecoration(
          hintText: widget.hint
        )
      ),

      suggestionsCallback: (pattern) async {
        queryParams["txt"] = pattern;
        var val = await fetchValues(queryParams, widget.reqType);
        return val.values;
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
