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

  final Map? doc;
  final FutureOr<List<dynamic>> Function(String)? findSuggestions;
  final dynamic Function(List<dynamic>)? valueTransformer;
  final Function(List<dynamic>)? onChanged;
  final Key? key;

  MultiSelect({
    required this.doctypeField,
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
    List<String? Function(dynamic)> validators = [];

    var f = setMandatory(widget.doctypeField);

    if (f != null) {
      validators.add(f(context));
    }

    var initialValue;
    if (widget.doc != null) {
      if (widget.doc![widget.doctypeField.fieldname] != null) {
        initialValue = widget.doc![widget.doctypeField.fieldname]
            .split(',')
            .where((e) => e != " ")
            .toList();
      } else {
        initialValue = [];
      }
    } else {
      initialValue = [];
    }

    return FormBuilderChipsInput(
      key: widget.key,
      onChanged: widget.onChanged,
      validator: FormBuilderValidators.compose(validators),
      valueTransformer: widget.valueTransformer ??
          (value) {
            return value
                .map((v) {
                  if (v is Map) {
                    return v["value"];
                  } else {
                    return v;
                  }
                })
                .toList()
                .join(',');
          },
      decoration: Palette.formFieldDecoration(
        label: widget.doctypeField.label,
      ),
      name: widget.doctypeField.fieldname,
      initialValue: initialValue,
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
            profile is Map ? profile["value"] : profile,
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
          title: Text(
            (profile as Map)["value"],
          ),
          onTap: () => state.selectSuggestion(profile),
        );
      },
    );
  }
}
