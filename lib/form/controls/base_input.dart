import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../model/doctype_response.dart';

class ControlInput {
  String? Function(dynamic) Function(BuildContext, {String errorText})?
      setMandatory(
    DoctypeField doctypeField,
  ) {
    if (doctypeField.reqd == 1) {
      return FormBuilderValidators.required;
    } else {
      return null;
    }
  }

  bool setBold(DoctypeField doctypeField) {
    if (doctypeField.reqd == 1 || doctypeField.bold == 1) {
      return true;
    } else {
      return false;
    }
  }
}
