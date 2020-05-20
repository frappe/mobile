import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/widgets/link_field.dart';

class LinkFormField extends StatefulWidget {
  final String hint;
  final String value;
  final String attribute;
  final String doctype;
  final String refDoctype;
  final String txt;

  final Function callback;

  LinkFormField({
    this.txt,
    @required this.attribute,
    @required this.hint,
    @required this.value,
    @required this.callback,
    @required this.doctype,
    @required this.refDoctype,
  });

  @override
  _LinkFormFieldState createState() => _LinkFormFieldState();
}

class _LinkFormFieldState extends State<LinkFormField> {
  @override
  Widget build(BuildContext context) {
    return FormBuilderCustomField(
      attribute: widget.attribute,
      validators: [
        // FormBuilderValidators.required(),
      ],
      formField: FormField(
        enabled: true,
        builder: (FormFieldState<dynamic> field) {
          return InputDecorator(
            decoration: InputDecoration(
              enabledBorder: InputBorder.none,
              errorText: field.errorText,
            ),
            child: LinkField(
              hint: widget.hint,
              value: widget.value,
              onSuggestionSelected: (item){
                field.didChange(item);
                widget.callback(item);
              },
              doctype: widget.doctype,
              refDoctype: widget.refDoctype,
            ),
          );
        },
      ),
    );
  }
}
