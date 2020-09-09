import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/palette.dart';

class Time extends StatelessWidget {
  final Key key;
  final String attribute;
  final dynamic value;
  final bool withLabel;
  final List<String Function(dynamic)> validators;
  final String label;
  final bool editMode;

  const Time({
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
      initialValue: value,
      inputType: InputType.time,
      valueTransformer: (val) {
        return val != null ? val.toIso8601String() : null;
      },
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
