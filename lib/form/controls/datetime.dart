import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/utils/helpers.dart';

class DatetimeField extends StatelessWidget {
  final Key key;
  final String attribute;
  final String value;
  final bool withLabel;
  final List<String Function(dynamic)> validators;
  final String label;
  final bool editMode;

  const DatetimeField({
    this.key,
    this.attribute,
    this.value,
    this.validators,
    this.label,
    this.withLabel,
    this.editMode,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderDateTimePicker(
      key: key,
      valueTransformer: (val) {
        return val != null ? val.toIso8601String() : null;
      },
      resetIcon: editMode ? Icon(Icons.close) : null,
      initialTime: null,
      initialValue: parseDate(value),
      name: attribute,
      decoration: Palette.formFieldDecoration(withLabel, label),
      validator: FormBuilderValidators.compose(validators),
    );
  }
}
