import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/form/controls/control.dart';
import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/utils/enums.dart';

class CustomForm extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  final List<DoctypeField> fields;
  final Map? doc;
  final ViewType? viewType;
  final void Function()? onChanged;

  const CustomForm({
    required this.formKey,
    required this.fields,
    this.viewType,
    this.doc,
    this.onChanged,
  });

  List<Widget> _generateChildren(
    List<DoctypeField> fields,
    Map? doc,
  ) {
    List<DoctypeField> filteredFields;

    if (viewType == ViewType.form) {
      filteredFields = fields.where(
        (field) {
          return (field.readOnly != 1 || field.fieldtype == "Section Break") &&
              field.hidden != 1 &&
              field.setOnlyOnce != 1 &&
              field.fieldtype != "Column Break";
        },
      ).toList();
    } else if (viewType == ViewType.newForm) {
      filteredFields = fields.where(
        (field) {
          return (field.readOnly != 1 || field.fieldtype == "Section Break") &&
              field.hidden != 1 &&
              field.fieldtype != "Column Break";
        },
      ).toList();
    } else {
      filteredFields = fields;
    }

    return generateLayout(
      fields: filteredFields,
      doc: doc,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          children: _generateChildren(
            fields,
            doc,
          ),
        ),
      ),
    );
  }
}
