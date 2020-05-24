import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../widgets/multi-select.dart';

class MultiSelectFormField extends StatefulWidget {
  final String hint;
  final String attribute;
  final Function callback;

  MultiSelectFormField({
    @required this.attribute,
    @required this.hint,
    @required this.callback,
  });

  @override
  _MultiSelectFormFieldState createState() => _MultiSelectFormFieldState();
}

class _MultiSelectFormFieldState extends State<MultiSelectFormField> {
  @override
  Widget build(BuildContext context) {
    return FormBuilderCustomField(
      attribute: widget.attribute,
      validators: [
        FormBuilderValidators.required(),
      ],
      formField: FormField(
        enabled: true,
        builder: (FormFieldState<dynamic> field) {
          return InputDecorator(
            decoration: InputDecoration(
              errorText: field.errorText,
              enabledBorder: InputBorder.none,
            ),
            child: MultiSelect(
              hint: widget.hint,
              callback: field.didChange,
            ),
          );
        },
      ),
    );
  }
}
