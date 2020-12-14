import 'package:flutter/material.dart';

import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/datamodels/doctype_response.dart';
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
  List<String Function(dynamic)> validators = [];

  switch (field.fieldtype) {
    case "Link":
      {
        fieldWidget = buildDecoratedWidget(
            LinkField(
              key: Key(value),
              fillColor: Palette.fieldBgColor,
              allowClear: editMode,
              validators: validators,
              attribute: field.fieldname,
              doctype: field.options,
              hint: !withLabel ? field.label : null,
              // refDoctype: field.ref,
              value: value,
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
            validators: validators,
            attribute: field.fieldname,
            options: field.options,
            hint: !withLabel ? field.label : null,
            value: value,
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
            doctype: field.options,
            items: value,
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
              value: value,
              allowClear: editMode,
              attribute: field.fieldname,
              validators: validators,
              options: field.options,
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
            attribute: field.fieldname,
            hint: field.label,
            val: value != null ? value : [],
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
            value: value,
            attribute: field.fieldname,
            withLabel: withLabel,
            validators: validators,
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
              value: value == 1,
              onChanged: onChanged,
              attribute: field.fieldname,
              label: field.label,
              validators: validators,
              withLabel: withLabel,
            ),
            false);
      }
      break;

    case "Text Editor":
      {
        fieldWidget = buildDecoratedWidget(
          TextEditor(
            value: value,
            attribute: field.fieldname,
            validators: validators,
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
            value: value,
            attribute: field.fieldname,
            validators: validators,
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
            value: value,
            attribute: field.fieldname,
            validators: validators,
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
            value: value,
            attribute: field.fieldname,
            validators: validators,
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
            value: value,
            attribute: field.fieldname,
            validators: validators,
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
            value: value,
            attribute: field.fieldname,
            validators: validators,
            withLabel: withLabel,
          ),
          withLabel,
          field.label,
        );
      }
      break;

    case "Signature":
      {
        fieldWidget = buildDecoratedWidget(
          customSignature.Signature(
            key: Key(value),
            value: value,
            attribute: field.fieldname,
            validators: validators,
            withLabel: withLabel,
          ),
          withLabel,
          field.label,
        );
      }
      break;

    case "Barcode":
      {
        fieldWidget = buildDecoratedWidget(
          FormBuilderBarcode(
            key: Key(value),
            initialValue: value,
            attribute: field.fieldname,
            validators: validators,
          ),
          withLabel,
          field.label,
        );
      }
      break;

    default:
      fieldWidget = Container();
      break;
  }
  return fieldWidget;
}
