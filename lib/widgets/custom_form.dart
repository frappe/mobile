import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/app/locator.dart';
import 'package:frappe_app/form/controls/control.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/services/api/api.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/utils/helpers.dart';

class CustomForm extends StatefulWidget {
  final GlobalKey<FormBuilderState> formKey;
  final List<DoctypeField> fields;
  final Map doc;
  final void Function()? onChanged;

  const CustomForm({
    required this.formKey,
    required this.fields,
    required this.doc,
    this.onChanged,
  });

  @override
  State<CustomForm> createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      onChanged: () {
        if (widget.formKey.currentState != null) {
          widget.formKey.currentState!.save();

          handleFormDataChange(widget.formKey.currentState!.value);
        }
        if (widget.onChanged != null) {
          widget.onChanged!();
        }
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          children: generateLayout(
            fields: widget.fields,
            doc: widget.doc,
            onControlChanged: (fieldValue, dependentFields) {
              handleControlDependencies(
                fieldValue: fieldValue,
                dependentFields: dependentFields,
                formKey: widget.formKey,
              );
            },
          ),
        ),
      ),
    );
  }

  handleFormDataChange(Map formValue) {}

  handleControlDependencies({
    required FieldValue fieldValue,
    required List<DoctypeField> dependentFields,
    required GlobalKey<FormBuilderState> formKey,
  }) async {
    var dependsOnFields =
        dependentFields.where((element) => element.dependsOn != null).toList();

    dependsOnFields.forEach(
      (element) {
        if (element.dependsOn!.startsWith("eval")) {
          var dd = jsonEncode(formKey.currentState?.value);
          // print(dd);
          var docProperty = element.dependsOn!.split("eval:")[1];
          var b = executeJS(jsString: """
            var doc = $dd;
            $docProperty
            """);

          print(b);
        } else {
          var showField = fieldValue.value == 1;
          var df =
              widget.fields.firstWhere((e) => e.fieldname == element.fieldname);
          df.pVisibile = showField;
          if (!showField) {
            formKey.currentState?.removeInternalFieldValue(element.fieldname);
          }
        }
      },
    );
    setState(() {});

    var fetchFromFields = dependentFields
        .where((element) {
          return element.fetchFrom != null &&
              element.fetchFrom!.split('.')[0] == fieldValue.field.fieldname;
        })
        .map((e) => {
              "fetch_from_field": e.fetchFrom!.split(".")[1],
              "fieldname": e.fieldname,
            })
        .toList();

    if (fetchFromFields.isNotEmpty) {
      var fetchFromVal = await locator<Api>().getdoc(
        fieldValue.field.options,
        fieldValue.value.toString(),
      );

      var fetchDoc = fetchFromVal.docs[0];
      Map<String, dynamic> fetchDoc1 = {};
      fetchFromFields.forEach(
        (element) {
          var v;
          // TODO use meta
          if (fetchDoc[element["fetch_from_field"]] == 1) {
            v = true;
          } else if (fetchDoc[element["fetch_from_field"]] == 0) {
            v = false;
          } else {
            v = fetchDoc[element["fetch_from_field"]].toString();
          }
          fetchDoc1[element["fieldname"] as String] = v;
        },
      );

      formKey.currentState!.patchValue(fetchDoc1);
      setState(() {});
    }
  }
}
