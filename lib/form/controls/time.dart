import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/model/doctype_response.dart';

import 'base_control.dart';
import 'base_input.dart';

class Time extends StatelessWidget with Control, ControlInput {
  final DoctypeField doctypeField;
  final Key? key;
  final Map? doc;

  const Time({
    required this.doctypeField,
    this.key,
    this.doc,
  });

  @override
  Widget build(BuildContext context) {
    List<String? Function(dynamic?)> validators = [];

    var f = setMandatory(doctypeField);

    if (f != null) {
      validators.add(
        f(context),
      );
    }

    return FormBuilderDateTimePicker(
      key: key,
      initialValue: doc != null
          ? DateFormat.Hms().parse(
              doc![doctypeField.fieldname],
            )
          : null,
      inputType: InputType.time,
      valueTransformer: (val) {
        return val.toIso8601String();
      },
      keyboardType: TextInputType.number,
      name: doctypeField.fieldname,
      decoration: Palette.formFieldDecoration(
        label: doctypeField.label,
      ),
      validator: FormBuilderValidators.compose(validators),
    );
  }
}
