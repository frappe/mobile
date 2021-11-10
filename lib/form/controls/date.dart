import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:frappe_app/model/offline_storage.dart';
import 'package:frappe_app/model/system_settings_response.dart';
import 'package:frappe_app/utils/constants.dart';
import 'package:intl/intl.dart';

import '../../config/palette.dart';
import '../../model/doctype_response.dart';
import '../../utils/helpers.dart';

import 'base_control.dart';
import 'base_input.dart';

class Date extends StatelessWidget with Control, ControlInput {
  final DoctypeField doctypeField;

  final Key? key;
  final Map? doc;

  const Date({
    this.key,
    required this.doctypeField,
    this.doc,
  });

  @override
  Widget build(BuildContext context) {
    List<String? Function(dynamic)> validators = [];

    var f = setMandatory(doctypeField);

    if (f != null) {
      validators.add(
        f(context),
      );
    }

    var systemSettings = jsonDecode(
      jsonEncode(
        OfflineStorage.getItem("systemSettings")["data"],
      ),
    );

    var dateFormat = systemSettings != null
        ? SystemSettingsResponse.fromJson(
            systemSettings,
          ).message.defaults.dateFormat
        : "dd-mm-yyyy";

    return FormBuilderDateTimePicker(
      key: key,
      inputType: InputType.date,
      valueTransformer: (val) {
        return val?.toIso8601String();
      },
      format: DateFormat(
        Constants.frappeFlutterDateFormatMapping[dateFormat],
      ),
      initialValue:
          doc != null ? parseDate(doc![doctypeField.fieldname]) : null,
      keyboardType: TextInputType.number,
      name: doctypeField.fieldname,
      decoration: Palette.formFieldDecoration(
        label: doctypeField.label,
      ),
      validator: FormBuilderValidators.compose(validators),
    );
  }
}
