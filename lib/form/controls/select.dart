import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/palette.dart';

class Select extends StatelessWidget {
  final Key key;
  final List options;
  final String attribute;
  final String value;
  final bool allowClear;
  final String hint;
  final List<String Function(dynamic)> validators;
  final String label;
  final bool withLabel;

  const Select({
    this.key,
    this.options,
    this.attribute,
    this.value,
    this.allowClear,
    this.hint,
    this.validators,
    this.label,
    this.withLabel,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderDropdown(
      key: key,
      initialValue: value,
      allowClear: allowClear,
      attribute: attribute,
      hint: hint != null ? Text(hint) : null,
      decoration: Palette.formFieldDecoration(
        withLabel,
        label,
      ),
      validators: validators,
      items: options.map<DropdownMenuItem>((option) {
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
