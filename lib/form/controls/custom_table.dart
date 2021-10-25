import 'package:flutter/material.dart';

import 'package:frappe_app/widgets/form_builder_table.dart';

import '../../model/doctype_response.dart';

class CustomTable extends StatelessWidget {
  final DoctypeField doctypeField;
  final Map doc;

  CustomTable({
    required this.doctypeField,
    required this.doc,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderTable(
      name: doctypeField.fieldname,
      context: context,
      doctype: doctypeField.options,
      initialValue: doc[doctypeField.fieldname],
    );
  }
}
