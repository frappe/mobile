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
import 'package:frappe_app/views/base_view.dart';
import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

class CustomForm extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BaseView<CustomFormViewModel>(
      onModelReady: (model) {
        model.doc = doc;
      },
      builder: (context, model, child) => FormBuilder(
        onChanged: () {
          if (formKey.currentState != null) {
            formKey.currentState!.save();

            model.handleFormDataChange(formKey.currentState!.value);
          }
          if (onChanged != null) {
            onChanged!();
          }
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: generateLayout(
              fields: fields,
              doc: model.doc,
              onControlChanged: (fieldValue, dependentFields) {
                model.handleFetchFrom(
                  dependentFields: dependentFields,
                  fieldValue: fieldValue,
                  formKey: formKey,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

@lazySingleton
class CustomFormViewModel extends BaseViewModel {
  late Map doc;

  handleFormDataChange(Map formValue) {
    doc = formValue;
    notifyListeners();
  }

  handleFetchFrom({
    required FieldValue fieldValue,
    required List<DoctypeField> dependentFields,
    required GlobalKey<FormBuilderState> formKey,
  }) async {
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
    }
  }
}
