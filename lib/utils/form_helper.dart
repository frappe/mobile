import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class FormHelper {
  late GlobalKey<FormBuilderState> _formKey;

  FormHelper() {
    _formKey = GlobalKey<FormBuilderState>();
  }

  GlobalKey<FormBuilderState> getKey() {
    return _formKey;
  }

  setFieldValue({
    required String fieldname,
    required Object value,
  }) {
    _formKey.currentState?.setInternalFieldValue(fieldname, value);
  }

  removeFieldValue(String name) {
    _formKey.currentState?.removeInternalFieldValue(name);
  }

  Object getValue(String fieldname) {
    return _formKey.currentState?.value[fieldname];
  }

  Map<String, dynamic> getFormValue() {
    return _formKey.currentState!.value;
  }

  updateValues(Map<String, dynamic> data) {
    _formKey.currentState?.patchValue(data);
  }

  save() {
    _formKey.currentState?.save();
  }

  bool saveAndValidate() {
    return _formKey.currentState!.saveAndValidate();
  }
}
