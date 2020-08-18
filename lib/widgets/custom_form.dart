import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/utils/helpers.dart';

class CustomForm extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  final List fields;
  final Map doc;
  final ViewType viewType;
  final bool editMode;

  const CustomForm({
    Key key,
    @required this.formKey,
    @required this.fields,
    this.viewType,
    this.doc,
    this.editMode = true,
  }) : super(key: key);

  List<Widget> _generateChildren(List fields, Map doc, bool editMode) {
    List filteredFields;

    if (viewType == ViewType.form) {
      filteredFields = fields.where(
        (field) {
          return (field["read_only"] != 1 ||
                  field["fieldtype"] == "Section Break") &&
              field["hidden"] != 1 &&
              field["set_only_once"] != 1;
        },
      ).map((field) {
        return {
          ...field,
          "_current_val": doc[field["fieldname"]],
        };
      }).toList();
    } else if (viewType == ViewType.newForm) {
      filteredFields = fields.where((field) {
        return (field["read_only"] != 1 ||
                field["fieldtype"] == "Section Break") &&
            field["hidden"] != 1;
      }).toList();
    } else {
      filteredFields = fields;
    }

    return generateLayout(
      fields: filteredFields,
      viewType: viewType,
      editMode: editMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      readOnly: editMode ? false : true,
      key: formKey,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: _generateChildren(
              fields,
              doc,
              editMode,
            ),
          ),
        ),
      ),
    );
  }
}
