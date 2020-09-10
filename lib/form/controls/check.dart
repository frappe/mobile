import 'package:flutter/material.dart';

import '../../config/frappe_palette.dart';
import '../../config/palette.dart';
import '../../widgets/custom_form_builder_checkbox.dart';

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
    return CustomFormBuilderCheckbox(
      key: key,
      valueTransformer: (val) {
        return val == true ? 1 : 0;
      },
      activeColor: FrappePalette.blue,
      leadingInput: true,
      initialValue: value == 1,
      onChanged: onChanged != null
          ? (val) {
              val = val == true ? 1 : 0;
              onChanged(val);
            }
          : null,
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
