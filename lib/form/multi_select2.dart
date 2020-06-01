import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/utils/response_models.dart';
import 'package:frappe_app/utils/rest_apis.dart';

class MultiSelect2 extends StatefulWidget {
  final String hint;
  final String attribute;
  final List val;

  MultiSelect2(
      {@required this.attribute,
      @required this.hint,
      this.val});
  @override
  _MultiSelect2State createState() => _MultiSelect2State();
}

class _MultiSelect2State extends State<MultiSelect2> {
  Future _fetchValues(Map data) {
    return getContactList(data);
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderChipsInput(
      valueTransformer: (l) {
        return l
            .map((a) {
              return a.value;
            })
            .toList()
            .join(',');
      },
      decoration: InputDecoration(labelText: "Users"),
      attribute: widget.attribute,
      initialValue: widget.val,
      findSuggestions: (String query) async {
        if (query.length != 0) {
          var lowercaseQuery = query.toLowerCase();
          var val = await _fetchValues({"txt": lowercaseQuery});
          if (val.values.length == 0) {
            val = [Contact(value: lowercaseQuery)];
          } else {
            val = val.values;
          }
          return val;
        } else {
          return [];
        }
      },
      chipBuilder: (context, state, profile) {
        return InputChip(
          label: Text(profile.value),
          onDeleted: () => state.deleteChip(profile),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      },
      suggestionBuilder: (context, state, profile) {
        return ListTile(
          title: Text(profile.value),
          onTap: () => state.selectSuggestion(profile),
        );
      },
    );
  }
}
