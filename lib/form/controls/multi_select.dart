import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/utils/response_models.dart';
import 'package:frappe_app/utils/rest_apis.dart';

class MultiSelect extends StatefulWidget {
  final String hint;
  final String attribute;
  final List val;

  MultiSelect({
    @required this.attribute,
    @required this.hint,
    this.val,
  });
  @override
  _MultiSelectState createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
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
      decoration: InputDecoration(
        filled: true,
        fillColor: Palette.fieldBgColor,
        enabledBorder: InputBorder.none,
        hintText: widget.hint,
      ),
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
          label: Text(
            profile.value,
            style: TextStyle(fontSize: 12),
          ),
          deleteIconColor: Palette.darkGrey,
          backgroundColor: Colors.transparent,
          shape: OutlineInputBorder(
            borderSide: BorderSide(
              color: Palette.borderColor,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
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
