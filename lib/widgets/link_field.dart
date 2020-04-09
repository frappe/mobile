import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:support_app/utils/http.dart';
import 'package:support_app/utils/response_models.dart';

Future<DioLinkFieldResponse> fetchLinkField(doctype, refDoctype, txt) async {
  var queryParams = {
    'txt': txt,
    'doctype': doctype,
    'reference_doctype': refDoctype,
    'ignore_user_permissions': 0
  };

  final response2 = await dio.post('/method/frappe.desk.search.search_link',
      data: queryParams,
      options: Options(contentType: Headers.formUrlEncodedContentType));
  if (response2.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return DioLinkFieldResponse.fromJson(response2.data);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class LinkField extends StatefulWidget {
  final value;
  final hint;
  final Function onSuggestionSelected;

  final doctype;
  final refDoctype;
  final txt;

  LinkField(
      {this.value,
      this.onSuggestionSelected,
      @required this.hint,
      @required this.doctype,
      @required this.refDoctype,
      this.txt});

  @override
  _LinkFieldState createState() => _LinkFieldState();
}

class _LinkFieldState extends State<LinkField> {
  // AutoCompleteTextField searchTextField;
  String dropdownVal;
  Future<DioLinkFieldResponse> futureVal;

  final TextEditingController _typeAheadController = TextEditingController();

  
  @override
  void initState() {
    super.initState();
    futureVal = fetchLinkField(widget.doctype, widget.refDoctype, widget.txt);
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: this._typeAheadController..text = widget.value,
      ),

      suggestionsCallback: (pattern) async {
        DioLinkFieldResponse val = await fetchLinkField(widget.doctype, widget.refDoctype, pattern);
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
