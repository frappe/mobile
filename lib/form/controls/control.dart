import 'package:flutter/material.dart';

import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/form/controls/barcode.dart';

import '../../config/palette.dart';
import '../../utils/helpers.dart';

import './custom_table.dart';
import './check.dart';
import './data.dart';
import './date.dart';
import './datetime.dart';
import './float.dart';
import './int.dart';
import './select.dart';
import './small_text.dart';
import './text_editor.dart';
import './time.dart';
import './autocomplete.dart';
import './link_field.dart';
import './multi_select.dart';
import './signature.dart' as customSignature;

Widget makeControl({
  @required DoctypeField field,
  dynamic value,
  Map doc,
  bool withLabel = true,
  bool editMode = true,
  Function onChanged,
}) {
  Widget fieldWidget;

  switch (field.fieldtype) {
    case "Link":
      {
        fieldWidget = buildDecoratedWidget(
            LinkField(
              key: Key(value),
              doctypeField: field,
              doc: doc,
              fillColor: Palette.fieldBgColor,
              allowClear: editMode,
              withLabel: withLabel,
            ),
            withLabel,
            field.label);
      }
      break;

    case "Autocomplete":
      {
        fieldWidget = buildDecoratedWidget(
          AutoComplete(
            key: Key(value),
            fillColor: Palette.fieldBgColor,
            allowClear: editMode,
            doctypeField: field,
            doc: doc,
          ),
          withLabel,
          field.label,
        );
      }
      break;

    case "Table":
      {
        fieldWidget = buildDecoratedWidget(
          CustomTable(
            doctypeField: field,
            doc: doc,
          ),
          withLabel,
          field.label,
        );
      }
      break;

    case "Select":
      {
        fieldWidget = buildDecoratedWidget(
            Select(
              key: Key(value),
              allowClear: editMode,
              doc: doc,
              doctypeField: field,
              withLabel: withLabel,
            ),
            withLabel,
            field.label);
      }
      break;

    case "MultiSelect":
      {
        if (value != null) {
          value = [
            {
              "value": value,
              "description": value,
            }
          ];
        }

        fieldWidget = buildDecoratedWidget(
          MultiSelect(
            doctypeField: field,
            doc: doc,
          ),
          withLabel,
          field.label,
        );
      }
      break;

    case "Small Text":
      {
        fieldWidget = buildDecoratedWidget(
          SmallText(
            key: Key(value),
            doctypeField: field,
            doc: doc,
            withLabel: withLabel,
          ),
          withLabel,
          field.label,
        );
      }
      break;

    case "Data":
      {
        fieldWidget = buildDecoratedWidget(
            Data(
              key: Key(value),
              doc: doc,
              doctypeField: field,
              withLabel: withLabel,
            ),
            withLabel,
            field.label);
      }
      break;

    case "Check":
      {
        fieldWidget = buildDecoratedWidget(
            Check(
              key: UniqueKey(),
              doctypeField: field,
              doc: doc,
              onChanged: onChanged,
              withLabel: withLabel,
            ),
            false);
      }
      break;

    case "Text Editor":
      {
        fieldWidget = buildDecoratedWidget(
          TextEditor(
            doctypeField: field,
            doc: doc,
            withLabel: withLabel,
          ),
          withLabel,
          field.label,
        );
      }
      break;

    case "Datetime":
      {
        fieldWidget = buildDecoratedWidget(
          DatetimeField(
            key: Key(value),
            doctypeField: field,
            doc: doc,
            withLabel: withLabel,
            editMode: editMode,
          ),
          withLabel,
          field.label,
        );
      }
      break;

    case "Float":
      {
        fieldWidget = buildDecoratedWidget(
          Float(
            key: Key(value.toString()),
            doctypeField: field,
            doc: doc,
            withLabel: withLabel,
          ),
          withLabel,
          field.label,
        );
      }
      break;

    case "Int":
      {
        fieldWidget = buildDecoratedWidget(
          Int(
            key: Key(value.toString()),
            doctypeField: field,
            doc: doc,
            withLabel: withLabel,
          ),
          withLabel,
          field.label,
        );
      }
      break;

    case "Time":
      {
        fieldWidget = buildDecoratedWidget(
          Time(
            key: Key(value),
            doctypeField: field,
            doc: doc,
            withLabel: withLabel,
          ),
          withLabel,
          field.label,
        );
      }
      break;

    case "Date":
      {
        fieldWidget = buildDecoratedWidget(
          Date(
            key: Key(value),
            doctypeField: field,
            doc: doc,
            withLabel: withLabel,
          ),
          withLabel,
          field.label,
        );
      }
      break;

    // case "Signature":
    //   {
    //     fieldWidget = buildDecoratedWidget(
    //       customSignature.Signature(
    //         key: Key(value),
    //         doc: doc,
    //         doctypeField: field,
    //         withLabel: withLabel,
    //       ),
    //       withLabel,
    //       field.label,
    //     );
    //   }
    //   break;

    // case "Barcode":
    //   {
    //     fieldWidget = buildDecoratedWidget(
    //       FormBuilderBarcode(
    //         key: Key(value),
    //         doctypeField: field,
    //         doc: doc,
    //       ),
    //       withLabel,
    //       field.label,
    //     );
    //   }
    //   break;

    default:
      fieldWidget = Container();
      break;
  }
  return fieldWidget;
}
