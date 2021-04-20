// @dart=2.9

import 'package:flutter/material.dart';
import 'package:frappe_app/model/doctype_response.dart';

import '../../config/frappe_palette.dart';
import '../../config/palette.dart';
import '../../widgets/custom_form_builder_checkbox.dart';

import 'base_control.dart';
import 'base_input.dart';

class Check extends StatelessWidget with Control, ControlInput {
  final Key key;
  final DoctypeField doctypeField;
  final Map doc;

  final bool withLabel;

  final Function onChanged;

  const Check({
    this.key,
    @required this.doctypeField,
    this.doc,
    this.withLabel,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    List<String Function(dynamic)> validators = [];

    var f = setMandatory(doctypeField);

    if (f != null) {
      validators.add(
        f(context),
      );
    }

    return CustomFormBuilderCheckbox(
      key: key,
      valueTransformer: (val) {
        return val == true ? 1 : 0;
      },
      activeColor: FrappePalette.blue,
      leadingInput: true,
      initialValue: doc != null ? doc[doctypeField.fieldname] == 1 : null,
      onChanged: onChanged != null
          ? (val) {
              val = val == true ? 1 : 0;
              onChanged(val);
            }
          : null,
      attribute: doctypeField.fieldname,
      label: Text(doctypeField.label),
      decoration: Palette.formFieldDecoration(
        withLabel: withLabel,
        label: doctypeField.label,
        filled: false,
        field: "check",
      ),
      validators: validators,
    );
  }
}
