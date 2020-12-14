import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/datamodels/doctype_response.dart';

import 'base_input.dart';
import 'base_control.dart';

class Data extends StatelessWidget with Control, ControlInput {
  final Key key;

  final bool withLabel;
  final DoctypeField doctypeField;
  final Map doc;

  const Data({
    this.key,
    this.withLabel,
    this.doctypeField,
    this.doc,
  });

  @override
  Widget build(BuildContext context) {
    List<String Function(dynamic)> validators = [];

    validators.add(
      setMandatory(
        doctypeField,
      ),
    );

    return FormBuilderTextField(
      key: key,
      initialValue: doc != null ? doc[doctypeField.fieldname] : null,
      attribute: doctypeField.fieldname,
      decoration: Palette.formFieldDecoration(withLabel, doctypeField.label),
      validators: validators,
    );
  }
}
