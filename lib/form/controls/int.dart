import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/datamodels/doctype_response.dart';

import '../../config/palette.dart';

import 'base_control.dart';
import 'base_input.dart';

class Int extends StatelessWidget with Control, ControlInput {
  final Key key;
  final DoctypeField doctypeField;
  final Map doc;

  final bool withLabel;

  final bool editMode;

  const Int({
    this.key,
    @required this.doctypeField,
    this.doc,
    this.withLabel,
    this.editMode,
  });

  @override
  Widget build(BuildContext context) {
    List<String Function(dynamic)> validators = [];

    validators.add(
      setMandatory(doctypeField, context),
    );

    return FormBuilderTextField(
      key: key,
      initialValue: doc != null
          ? doc[doctypeField.fieldname] != null
              ? doc[doctypeField.fieldname].toString()
              : null
          : null,
      keyboardType: TextInputType.number,
      name: doctypeField.fieldname,
      decoration: Palette.formFieldDecoration(
        withLabel,
        doctypeField.label,
      ),
      validator: FormBuilderValidators.compose(validators),
    );
  }
}
