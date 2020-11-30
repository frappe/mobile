import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/palette.dart';

class Signature extends StatelessWidget {
  final Key key;
  final String attribute;
  final dynamic value;
  final bool withLabel;
  final List<String Function(dynamic)> validators;
  final String label;

  const Signature({
    this.key,
    this.attribute,
    this.value,
    this.validators,
    this.label,
    this.withLabel,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderSignaturePad(
      initialValue: value != null ? base64.decode(value.split(',').last) : null,
      key: key,
      decoration: Palette.formFieldDecoration(
        withLabel,
        label,
      ),
      attribute: attribute,
      validators: validators,
    );
  }
}
