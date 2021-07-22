import 'package:flutter/material.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/model/doctype_response.dart';

import '../../config/frappe_palette.dart';
import '../../config/palette.dart';
import '../../widgets/custom_form_builder_checkbox.dart';

import 'base_control.dart';
import 'base_input.dart';

class Check extends StatelessWidget with Control, ControlInput {
  final DoctypeField doctypeField;
  final OnControlChanged? onControlChanged;
  final Key? key;
  final Map? doc;

  const Check({
    required this.doctypeField,
    this.onControlChanged,
    this.key,
    this.doc,
  });

  @override
  Widget build(BuildContext context) {
    List<String? Function(dynamic)> validators = [];

    var f = setMandatory(doctypeField);

    if (f != null) {
      validators.add(
        f(context),
      );
    }

    // TODO fix overflow
    return CustomFormBuilderCheckbox(
      key: key,
      valueTransformer: (val) {
        return val == true ? 1 : 0;
      },
      activeColor: FrappePalette.blue,
      leadingInput: true,
      initialValue: doc != null ? doc![doctypeField.fieldname] == 1 : null,
      onChanged: (val) {
        if (onControlChanged != null) {
          onControlChanged!(
            FieldValue(
              field: doctypeField,
              value: val,
            ),
          );
        }
      },
      attribute: doctypeField.fieldname,
      label: Text(
        doctypeField.label!,
      ),
      decoration: Palette.formFieldDecoration(
        label: doctypeField.label,
        filled: false,
        field: "check",
      ),
      validators: validators,
    );
  }
}
