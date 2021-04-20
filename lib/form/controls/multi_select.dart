// @dart=2.9

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/widgets/form_builder_chips_input.dart';

import '../../model/doctype_response.dart';
import '../../app/locator.dart';
import '../../config/palette.dart';
import '../../services/api/api.dart';

import 'base_input.dart';
import 'base_control.dart';

class MultiSelect extends StatefulWidget {
  final DoctypeField doctypeField;
  final Map doc;
  final FutureOr<List<dynamic>> Function(String) findSuggestions;
  final dynamic Function(List<dynamic>) valueTransformer;
  final Function(List<dynamic>) onChanged;
  final Key key;

  MultiSelect({
    @required this.doctypeField,
    this.doc,
    this.key,
    this.findSuggestions,
    this.valueTransformer,
    this.onChanged,
  });
  @override
  _MultiSelectState createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> with Control, ControlInput {
  @override
  Widget build(BuildContext context) {
    return FormBuilderChipsInput(
      key: widget.key,
      onChanged: widget.onChanged,
      valueTransformer: widget.valueTransformer ??
          (l) {
            return l
                .map((a) {
                  return a["value"];
                })
                .toList()
                .join(',');
          },
      decoration: Palette.formFieldDecoration(
        label: widget.doctypeField.label,
        withLabel: false,
      ),
      name: widget.doctypeField.fieldname,
      initialValue:
          widget.doc != null ? widget.doc[widget.doctypeField.fieldname] : [],
      findSuggestions: widget.findSuggestions ??
          (String query) async {
            if (query.length != 0) {
              var lowercaseQuery = query.toLowerCase();
              var response =
                  await locator<Api>().getContactList(lowercaseQuery);
              var val = response["message"];
              if (val.length == 0) {
                val = [
                  {
                    "value": lowercaseQuery,
                    "description": lowercaseQuery,
                  }
                ];
              }
              return val;
            } else {
              return [];
            }
          },
      chipBuilder: (context, state, profile) {
        return InputChip(
          label: Text(
            profile["value"],
            style: TextStyle(fontSize: 12),
          ),
          deleteIconColor: Palette.iconColor,
          backgroundColor: Colors.white,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          onDeleted: () => state.deleteChip(profile),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      },
      suggestionBuilder: (context, state, profile) {
        return ListTile(
          title: Text(profile["value"]),
          onTap: () => state.selectSuggestion(profile),
        );
      },
    );
  }
}
