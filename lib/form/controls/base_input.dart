import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../datamodels/doctype_response.dart';

class ControlInput {
  String Function(dynamic) setMandatory(DoctypeField doctypeField) {
    if (doctypeField.reqd == 1) {
      return FormBuilderValidators.required();
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
