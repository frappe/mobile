import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:support_app/utils/rest_apis.dart';

Future fetchLinkField(doctype, refDoctype, txt) async {
  var queryParams = {
    'txt': txt,
    'doctype': doctype,
    'reference_doctype': refDoctype,
    'ignore_user_permissions': 0
  };

  return search_link(queryParams);
}

Future fetch_values(Map data, String req_type) {
  if(req_type == 'get_contact_list') {
    return get_contact_list(data);
  }
  return search_link(data);
}

class LinkField extends StatefulWidget {
  final value;
  final hint;
  final Function onSuggestionSelected;

  final doctype;
  final refDoctype;
  final txt;
  final req_type;

  LinkField(
      {this.value,
      this.req_type,
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
  var query_params;

  final TextEditingController _typeAheadController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if(widget.req_type == 'get_contact_list') {
      query_params = {
        'txt': widget.txt
      };
    } else {
      query_params = {
        'txt': widget.txt,
        'doctype': widget.doctype,
        'reference_doctype': widget.refDoctype,
        'ignore_user_permissions': 0
      };
    }
    futureVal = fetch_values(query_params, widget.req_type);
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
        query_params["txt"] = pattern;
        var val = await fetch_values(query_params, widget.req_type);
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
