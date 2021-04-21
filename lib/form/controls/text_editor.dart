// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/image_render.dart';
import 'package:frappe_app/model/config.dart';
import 'package:frappe_app/widgets/form_builder_text_editor.dart';
// import 'package:html_editor_enhanced/html_editor.dart';

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
    this.readOnly = false,
    this.doc,
    this.withLabel,
  });

  @override
  Widget build(BuildContext context) {
    List<String Function(dynamic)> validators = [];

    var f = setMandatory(doctypeField);

    if (f != null) {
      validators.add(
        f(context),
      );
    }
    return FormBuilderTextEditor(
      onTap: (field) async {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return EditText(
                data: doc != null ? doc[doctypeField.fieldname] : null,
              );
            },
          ),
        );
      },
      key: key,
      initialValue: doc != null ? doc[doctypeField.fieldname] : null,
      name: doctypeField.fieldname,
      enabled: !readOnly,
      // validator: FormBuilderValidators.compose(validators),
    );
  }
}

class EditText extends StatelessWidget {
  final String data;
  const EditText({
    Key key,
    this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Html(
        onImageError: (e, ee) {
          print("e $e");
          print("ee $ee");
        },
        data: data,
        customImageRenders: {
          (attr, _) => attr["src"] != null: networkImageRender(mapUrl: (url) {
            return Config().baseUrl + url;
          }),
        },
      ),
    );
  }
}
