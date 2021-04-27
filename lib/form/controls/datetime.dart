import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/widgets/form_builder_date_time_picker.dart';

import '../../config/palette.dart';
import '../../model/doctype_response.dart';
import '../../utils/helpers.dart';

import 'base_control.dart';
import 'base_input.dart';

class DatetimeField extends StatelessWidget with Control, ControlInput {
  final DoctypeField doctypeField;

  final Key? key;
  final Map? doc;

  const DatetimeField({
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
      valueTransformer: (val) {
        return val.toIso8601String();
      },
      resetIcon: Icon(Icons.close),
      initialTime: null,
      initialValue:
          doc != null ? parseDate(doc![doctypeField.fieldname]) : null,
      name: doctypeField.fieldname,
      decoration: Palette.formFieldDecoration(
        label: doctypeField.label,
      ),
      validator: FormBuilderValidators.compose(validators),
    );
  }
}
