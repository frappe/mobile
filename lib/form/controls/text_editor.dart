import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:frappe_app/widgets/form_builder_text_editor.dart';

import '../../model/doctype_response.dart';

import 'base_control.dart';
import 'base_input.dart';

class TextEditor extends StatelessWidget with Control, ControlInput {
  final DoctypeField doctypeField;
  final Key? key;
  final Map? doc;
  final Color? color;
  final bool fullHeight;

  const TextEditor({
    required this.doctypeField,
    this.key,
    this.doc,
    this.color,
    this.fullHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    List<String? Function(dynamic)> validators = [];

    var f = setMandatory(doctypeField);

    if (f != null) {
      validators.add(
        f(context),
      );
    }

    return FormBuilderTextEditor(
      key: key,
      fullHeight: fullHeight,
      initialValue: doc != null ? doc![doctypeField.fieldname] : null,
      name: doctypeField.fieldname,
      context: context,
      color: color,
      validator: FormBuilderValidators.compose(validators),
    );
  }
}
