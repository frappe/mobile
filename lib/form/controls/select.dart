import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/utils/frappe_icon.dart';

import '../../config/palette.dart';
import '../../model/doctype_response.dart';

import 'base_control.dart';
import 'base_input.dart';

class Select extends StatelessWidget with Control, ControlInput {
  final DoctypeField doctypeField;
  final OnControlChanged? onControlChanged;

  final Key? key;
  final Map? doc;

  const Select({
    this.key,
    required this.doctypeField,
    this.doc,
    this.onControlChanged,
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

    List opts;
    if (doctypeField.options is String) {
      opts = doctypeField.options.split('\n');
    } else {
      opts = doctypeField.options ?? [];
    }

    return FormBuilderDropdown(
      key: key,
      onChanged: (dynamic val) {
        if (onControlChanged != null) {
          onControlChanged!(
            FieldValue(
              field: doctypeField,
              value: val,
            ),
          );
        }
      },
      icon: FrappeIcon(
        FrappeIcons.select,
      ),
      initialValue: doc != null
          ? doc![doctypeField.fieldname]
          : doctypeField.defaultValue,
      name: doctypeField.fieldname,
      hint: Text(doctypeField.label!),
      decoration: Palette.formFieldDecoration(
        label: doctypeField.label,
      ),
      validator: FormBuilderValidators.compose(validators),
      items: opts.toSet().toList().map<DropdownMenuItem>((option) {
        return DropdownMenuItem(
          value: option,
          child: option != null
              ? Text(
                  option,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                )
              : Text(''),
        );
      }).toList(),
    );
  }
}
