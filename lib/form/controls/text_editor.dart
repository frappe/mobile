// @dart=2.9
import 'package:flutter/material.dart';
import 'package:frappe_app/widgets/form_builder_text_editor.dart';

import '../../config/palette.dart';
import '../../model/doctype_response.dart';

import 'base_control.dart';
import 'base_input.dart';

class TextEditor extends StatelessWidget with Control, ControlInput {
  final Key key;
  final DoctypeField doctypeField;
  final Map doc;
  final bool readOnly;

  final bool withLabel;

  const TextEditor({
    this.key,
    @required this.doctypeField,
    this.readOnly,
    this.doc,
    this.withLabel,
  });

  @override
  Widget build(BuildContext context) {
    List<String Function(dynamic)> validators = [];

    String Function(dynamic) Function(BuildContext, {String errorText}) f =
        setMandatory(doctypeField);

    if (f != null) {
      validators.add(
        f(context),
      );
    }
    return FormBuilderTextEditor(
      onTap: (field) async {
        var v = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              var _controller = TextEditingController();
              return Scaffold(
                appBar: AppBar(
                  actions: [
                    FlatButton(
                      child: Text('save'),
                      onPressed: () {
                        Navigator.of(context).pop(_controller.text);
                      },
                    ),
                  ],
                ),
                body: TextField(
                  controller: _controller,
                ),
              );
            },
          ),
        );

        if (v != null) {
          field.didChange(v);
        }
      },
      key: key,
      initialValue: doc != null ? doc[doctypeField.fieldname] : null,
      name: doctypeField.fieldname,
      enabled: !readOnly,
      // validator: FormBuilderValidators.compose(validators),
    );
  }
}
