import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/utils/helpers.dart';

class Date extends StatelessWidget {
  final Key key;
  final String attribute;
  final dynamic value;
  final bool withLabel;
  final List<String Function(dynamic)> validators;
  final String label;
  final bool editMode;

  const Date({
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
      inputType: InputType.date,
      valueTransformer: (val) {
        return val != null ? val.toIso8601String() : null;
      },
      initialValue: parseDate(value),
      keyboardType: TextInputType.number,
      attribute: attribute,
      decoration: Palette.formFieldDecoration(
        withLabel,
        label,
      ),
      validators: validators,
    );
  }
}
