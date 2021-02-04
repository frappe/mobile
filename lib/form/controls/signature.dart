import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../config/palette.dart';
import '../../model/doctype_response.dart';

import 'base_control.dart';
import 'base_input.dart';

class Signature extends StatelessWidget with Control, ControlInput {
  final Key key;
  final DoctypeField doctypeField;
  final Map doc;
  final bool withLabel;

  const Signature({
    this.key,
    @required this.doctypeField,
    this.doc,
    this.withLabel,
  });

  @override
  Widget build(BuildContext context) {
    List<String Function(dynamic)> validators = [];

    validators.add(
      setMandatory(doctypeField)(context),
    );
    return FormBuilderSignaturePad(
      initialValue: doc != null
          ? doc[doctypeField.fieldname] != null
              ? base64.decode(doc[doctypeField.fieldname].split(',').last)
              : null
          : null,
      key: key,
      decoration: Palette.formFieldDecoration(
        withLabel,
        doctypeField.label,
      ),
      name: doctypeField.name,
      validator: FormBuilderValidators.compose(validators),
    );
  }
}
