import 'package:flutter/material.dart';
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

class AddReviewBottomSheetView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BaseView<AddReviewBottomSheetViewModel>(
      onModelReady: (model) {
        model.getReviewFormFields(
          doc: doc,
          docInfo: docinfo,
          meta: meta,
        );
        model.formObj = {
          "to_user": null,
          "review_type": model.fields[1].defaultValue,
          "points": null,
          "reason": null,
        };
      },
      builder: (context, model, child) => FractionallySizedBox(
        heightFactor: 0.6,
        child: FrappeBottomSheet(
          title: 'Add Review',
          onActionButtonPress: () async {
            try {
              await model.addReview(
                doctype: meta.name,
                name: name,
              );
              Navigator.of(context).pop(true);
            } catch (e) {
              FrappeAlert.errorAlert(
                title: (e as ErrorResponse).statusMessage,
                context: context,
              );
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
              child: Column(
                children: [
                  buildDecoratedControl(
                    field: model.fields[0],
                    control: AutoComplete(
                      doctypeField: model.fields[0],
                      onSuggestionSelected: (v) {
                        model.formObj["to_user"] = v;
                      },
                    ),
                  ),
                  buildDecoratedControl(
                    field: model.fields[1],
                    control: Select(
                      doctypeField: model.fields[1],
                      onChanged: (v) {
                        model.formObj["action"] = v;
                      },
                    ),
                  ),
                  buildDecoratedControl(
                    field: model.fields[2],
                    control: Int(
                      doctypeField: model.fields[2],
                      onChanged: (v) {
                        model.formObj["points"] = v;
                      },
                    ),
                  ),
                  buildDecoratedControl(
                    field: model.fields[3],
                    control: SmallText(
                      doctypeField: model.fields[3],
                      onChanged: (v) {
                        model.formObj["reason"] = v;
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
