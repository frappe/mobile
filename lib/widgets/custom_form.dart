import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/form/controls/control.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/utils/enums.dart';
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
              onControlChanged: (v) {},
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
}
