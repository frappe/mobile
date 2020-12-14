import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/palette.dart';

class SmallText extends StatelessWidget {
  final Key key;
  final String attribute;
  final String value;
  final bool withLabel;
  final String hint;
  final List<String Function(dynamic)> validators;
  final String label;

  const SmallText({
    this.key,
    this.attribute,
    this.value,
    this.hint,
    this.validators,
    this.label,
    this.withLabel,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      key: key,
      initialValue: value,
      name: attribute,
      decoration: Palette.formFieldDecoration(
        withLabel,
        label,
      ),
      validator: FormBuilderValidators.compose(validators),
    );
  }
}
