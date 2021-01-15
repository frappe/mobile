import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../config/palette.dart';
import '../../datamodels/doctype_response.dart';

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
      initialValue: doc != null ? doc[doctypeField.fieldname] : null,
      allowClear: allowClear,
      name: doctypeField.fieldname,
      hint: !withLabel ? Text(doctypeField.label) : null,
      decoration: Palette.formFieldDecoration(
        withLabel,
        doctypeField.label,
      ),
      validator: FormBuilderValidators.compose(validators),
      items: opts.map<DropdownMenuItem>((option) {
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
