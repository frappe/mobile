import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../config/palette.dart';
import '../../model/doctype_response.dart';
import '../../utils/helpers.dart';

import 'base_control.dart';
import 'base_input.dart';

class DatetimeField extends StatelessWidget with Control, ControlInput {
  final Key key;
  final Map doc;
  final DoctypeField doctypeField;
  final bool withLabel;
  final bool editMode;

  const DatetimeField({
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
      valueTransformer: (val) {
        return val != null ? val.toIso8601String() : null;
      },
      resetIcon: editMode ? Icon(Icons.close) : null,
      initialTime: null,
      initialValue: doc != null ? parseDate(doc[doctypeField.fieldname]) : null,
      name: doctypeField.fieldname,
      decoration: Palette.formFieldDecoration(withLabel, doctypeField.label),
      validator: FormBuilderValidators.compose(validators),
    );
  }
}
