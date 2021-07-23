import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/form/controls/autocomplete.dart';
import 'package:frappe_app/form/controls/control.dart';
import 'package:frappe_app/form/controls/int.dart';
import 'package:frappe_app/form/controls/select.dart';
import 'package:frappe_app/form/controls/small_text.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/model/get_doc_response.dart';
import 'package:frappe_app/utils/frappe_alert.dart';

import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/base_view.dart';

import 'package:frappe_app/widgets/frappe_bottom_sheet.dart';

import 'add_review_bottom_sheet_viewmodel.dart';

class AddReviewBottomSheetView extends StatefulWidget {
  final String name;
  final DoctypeDoc meta;
  final Map doc;
  final Docinfo docinfo;

  AddReviewBottomSheetView({
    required this.name,
    required this.meta,
    required this.doc,
    required this.docinfo,
  });

  @override
  _AddReviewBottomSheetViewState createState() =>
      _AddReviewBottomSheetViewState();
}

class _AddReviewBottomSheetViewState extends State<AddReviewBottomSheetView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return BaseView<AddReviewBottomSheetViewModel>(
      onModelReady: (model) {
        model.getReviewFormFields(
          doc: widget.doc,
          docInfo: widget.docinfo,
          meta: widget.meta,
        );
      },
      builder: (context, model, child) => AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets,
        duration: const Duration(milliseconds: 100),
        child: FractionallySizedBox(
          heightFactor: 0.6,
          child: FrappeBottomSheet(
            title: 'Add Review',
            onActionButtonPress: () async {
              if (_fbKey.currentState != null) {
                if (_fbKey.currentState!.saveAndValidate()) {
                  try {
                    await model.addReview(
                      doctype: widget.meta.name,
                      name: widget.name,
                      formObj: _fbKey.currentState!.value,
                    );
                    Navigator.of(context).pop(true);
                  } catch (e) {
                    FrappeAlert.errorAlert(
                      title: (e as ErrorResponse).statusMessage,
                      context: context,
                    );
                  }
                }
              }
            },
            trailing: Row(
              children: [
                FrappeIcon(
                  FrappeIcons.small_add,
                  color: FrappePalette.blue[500],
                  size: 16,
                ),
                Text(
                  'Add',
                  style: TextStyle(
                    color: FrappePalette.blue[500],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            body: Container(
              color: Colors.white,
              height: double.infinity,
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: _fbKey,
                  child: Column(
                    children: [
                      buildDecoratedControl(
                        field: model.fields[0],
                        control: AutoComplete(
                          doctypeField: model.fields[0],
                        ),
                      ),
                      buildDecoratedControl(
                        field: model.fields[1],
                        control: Select(
                          doctypeField: model.fields[1],
                        ),
                      ),
                      buildDecoratedControl(
                        field: model.fields[2],
                        control: Int(
                          doctypeField: model.fields[2],
                        ),
                      ),
                      buildDecoratedControl(
                        field: model.fields[3],
                        control: SmallText(
                          doctypeField: model.fields[3],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
