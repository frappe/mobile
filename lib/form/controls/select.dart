// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/utils/frappe_icon.dart';

import '../../config/palette.dart';
import '../../model/doctype_response.dart';

import 'base_control.dart';
import 'base_input.dart';

class Select extends StatelessWidget with Control, ControlInput {
  final Key key;
  final DoctypeField doctypeField;
  final Map doc;

  final bool allowClear;

  final bool withLabel;

  const Select({
    this.key,
    this.doctypeField,
    this.doc,
    this.allowClear,
    this.withLabel,
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

    List opts;
    if (doctypeField.options is String) {
      opts = doctypeField.options.split('\n');
    } else {
      opts = doctypeField.options ?? [];
    }

    return FormBuilderDropdown(
      key: key,
      icon: FrappeIcon(
        FrappeIcons.select,
      ),
      initialValue:
          doc != null ? doc[doctypeField.fieldname] : doctypeField.defaultValue,
      allowClear: allowClear,
      name: doctypeField.fieldname,
      hint: !withLabel ? Text(doctypeField.label) : null,
      decoration: Palette.formFieldDecoration(
        withLabel: withLabel,
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
