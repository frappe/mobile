import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/widgets/form_builder_text_editor.dart';

import '../../model/doctype_response.dart';

import 'base_control.dart';
import 'base_input.dart';

class TextEditor extends StatelessWidget with Control, ControlInput {
  final DoctypeField doctypeField;
  final Key? key;
  final Map? doc;

  const TextEditor({
    required this.doctypeField,
    this.key,
    this.doc,
  });

  @override
  Widget build(BuildContext context) {
    List<String? Function(dynamic?)> validators = [];

    var f = setMandatory(doctypeField);

    if (f != null) {
      validators.add(
        f(context),
      );
    }

    return FormBuilderTextEditor(
      key: key,
      initialValue: doc != null ? doc![doctypeField.fieldname] : null,
      name: doctypeField.fieldname,
      context: context,
      validator: FormBuilderValidators.compose(validators),
    );
  }
}
