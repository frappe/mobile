import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/palette.dart';

class Check extends StatelessWidget {
  final Key key;
  final String attribute;
  final dynamic value;
  final bool withLabel;
  final String hint;
  final List<String Function(dynamic)> validators;
  final String label;
  final Function onChanged;

  const Check({
    this.key,
    this.attribute,
    this.value,
    this.hint,
    this.validators,
    this.label,
    this.withLabel,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderCheckbox(
      valueTransformer: (val) {
        return val == true ? 1 : 0;
      },
      leadingInput: true,
      initialValue: value == 1,
      onChanged: onChanged != null
          ? (val) {
              val = val == true ? 1 : 0;
              onChanged(val);
            }
          : null,
      key: UniqueKey(),
      attribute: attribute,
      label: Text(label),
      decoration: Palette.formFieldDecoration(
        withLabel,
        label,
        null,
        false,
      ),
      validators: validators,
    );
  }
}
