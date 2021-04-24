import 'package:flutter/material.dart';

import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/model/doctype_response.dart';

import '../../config/palette.dart';

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

Widget makeControl({
  required DoctypeField field,
  Map? doc,
  bool withLabel = true,
  bool editMode = true,
  bool decorateControl = true,
}) {
  Widget control;

  switch (field.fieldtype) {
    case "Link":
      {
        control = LinkField(
          doctypeField: field,
          doc: doc,
          fillColor: Palette.fieldBgColor,
          allowClear: editMode,
          withLabel: withLabel,
        );
      }
      break;

    case "Autocomplete":
      {
        control = AutoComplete(
          fillColor: Palette.fieldBgColor,
          allowClear: editMode,
          doctypeField: field,
          doc: doc,
        );
      }
      break;

    case "Table":
      {
        control = CustomTable(
          doctypeField: field,
          doc: doc,
        );
      }
      break;

    case "Select":
      {
        control = Select(
          allowClear: editMode,
          doc: doc,
          doctypeField: field,
          withLabel: withLabel,
        );
      }
      break;

    case "MultiSelect":
      {
        control = MultiSelect(
          doctypeField: field,
          doc: doc,
        );
      }
      break;

    case "Small Text":
      {
        control = SmallText(
          doctypeField: field,
          doc: doc,
          withLabel: withLabel,
        );
      }
      break;

    case "Data":
      {
        control = Data(
          doc: doc,
          doctypeField: field,
          withLabel: withLabel,
        );
      }
      break;

    case "Check":
      {
        control = Check(
          doctypeField: field,
          doc: doc,
          withLabel: withLabel,
        );
      }
      break;

    case "Text Editor":
      {
        control = TextEditor(
          doctypeField: field,
          doc: doc,
          withLabel: withLabel,
        );
      }
      break;

    // TODO: temp fix
    case "Text Editor2":
      {
        control = TextEditor2(
          doctypeField: field,
          doc: doc,
          withLabel: withLabel,
        );
      }
      break;

    case "Datetime":
      {
        control = DatetimeField(
          doctypeField: field,
          doc: doc,
          withLabel: withLabel,
          editMode: editMode,
        );
      }
      break;

    case "Float":
      {
        control = Float(
          doctypeField: field,
          doc: doc,
          withLabel: withLabel,
        );
      }
      break;

    case "Int":
      {
        control = Int(
          doctypeField: field,
          doc: doc,
          withLabel: withLabel,
        );
      }
      break;

    case "Time":
      {
        control = Time(
          doctypeField: field,
          doc: doc,
          withLabel: withLabel,
        );
      }
      break;

    case "Date":
      {
        control = Date(
          doctypeField: field,
          doc: doc,
          withLabel: withLabel,
        );
      }
      break;

    // case "Signature":
    //   {
    //     control = customSignature.Signature(
    //       doc: doc,
    //       doctypeField: field,
    //       withLabel: withLabel,
    //     );
    //   }
    //   break;

    // case "Barcode":
    //   {
    //     control = FormBuilderBarcode(
    //       doctypeField: field,
    //       doc: doc,
    //     );
    //   }
    //   break;

    default:
      control = Container();
      break;
  }
  if (decorateControl) {
    return buildDecoratedControl(
      control: control,
      withLabel: withLabel,
      label: field.label,
    );
  } else {
    return control;
  }
}

Widget buildDecoratedControl({
  required Widget control,
  required bool withLabel,
  String? label = "",
}) {
  if (withLabel) {
    return Padding(
      padding: Palette.fieldPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: Palette.labelPadding,
            child: Text(
              label ?? "",
              style: Palette.secondaryTxtStyle,
            ),
          ),
          control
        ],
      ),
    );
  } else {
    return Padding(
      padding: Palette.fieldPadding,
      child: control,
    );
  }
}
