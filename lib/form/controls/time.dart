import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/model/doctype_response.dart';

import 'base_control.dart';
import 'base_input.dart';

class Time extends StatelessWidget with Control, ControlInput {
  final Key key;
  final DoctypeField doctypeField;
  final Map doc;
  final bool withLabel;
  final bool editMode;

  const Time({
    this.key,
    @required this.doctypeField,
    this.doc,
    this.withLabel,
    this.editMode,
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

    return FormBuilderDateTimePicker(
      key: key,
      initialValue: doc != null
          ? DateFormat.Hms().parse(
              doc[doctypeField.fieldname],
            )
          : null,
      inputType: InputType.time,
      valueTransformer: (val) {
        return val != null ? val.toIso8601String() : null;
      },
      keyboardType: TextInputType.number,
      name: doctypeField.fieldname,
      decoration: Palette.formFieldDecoration(
        withLabel,
        doctypeField.label,
      ),
      validator: FormBuilderValidators.compose(validators),
    );
  }
}
