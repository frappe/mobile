import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/base_view.dart';
import 'package:frappe_app/views/list_view/bottom_sheets/sort_by_fields_bottom_sheet_viewmodel.dart';
import 'package:frappe_app/widgets/frappe_bottom_sheet.dart';

class SortByFieldsBottomSheetView extends StatelessWidget {
  final List<DoctypeField> fields;
  final DoctypeField selectedField;

  SortByFieldsBottomSheetView({
    required this.fields,
    required this.selectedField,
  });

  @override
  Widget build(BuildContext context) {
    return BaseView<SortByFieldsBottomSheetViewModel>(
      onModelReady: (model) {
        model.selectedField = selectedField;
      },
      builder: (context, model, child) => FractionallySizedBox(
        heightFactor: 0.5,
        child: FrappeBottomSheet(
          title: 'Sort By',
          onActionButtonPress: () {
            Navigator.of(context).pop(
              {
                "field": model.selectedField,
                "order": model.sortOrder,
              },
            );
          },
          trailing: Text(
            'Done',
            style: TextStyle(
              color: FrappePalette.blue[500],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          body: Scrollbar(
            // isAlwaysShown: true,
            child: ListView(
                children: fields.map((field) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    6,
                  ),
                  color: field.fieldname == model.selectedField.fieldname
                      ? FrappePalette.grey[100]
                      : null,
                ),
                child: ListTile(
                  onTap: () {
                    model.selectField(field);
                  },
                  trailing: field.fieldname == model.selectedField.fieldname
                      ? FrappeIcon(
                          model.sortOrder == "desc"
                              ? FrappeIcons.sort_descending
                              : FrappeIcons.sort_ascending,
                        )
                      : null,
                  visualDensity: VisualDensity(vertical: -4),
                  title: Text(
                    field.label!,
                    style: TextStyle(),
                  ),
                ),
              );
            }).toList()),
          ),
        ),
      ),
    );
  }
}
