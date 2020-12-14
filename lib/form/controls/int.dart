import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/palette.dart';

class Int extends StatelessWidget {
  final Key key;
  final String attribute;
  final dynamic value;
  final bool withLabel;
  final List<String Function(dynamic)> validators;
  final String label;
  final bool editMode;

  const Int({
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
    return FormBuilderTextField(
      key: key,
      valueTransformer: (val) {
        if (val == "") {
          return val;
        }
        return int.parse(val);
      },
      initialValue: value != null ? value.toString() : null,
      keyboardType: TextInputType.number,
      name: attribute,
      decoration: Palette.formFieldDecoration(
        withLabel,
        label,
      ),
      validator: FormBuilderValidators.compose(validators),
    );
  }
}
