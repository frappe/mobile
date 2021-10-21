import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frappe_app/app/locator.dart';
import 'package:frappe_app/config/frappe_palette.dart';

import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/form/controls/currency.dart';
import 'package:frappe_app/form/controls/dynamic_link.dart';
import 'package:frappe_app/form/controls/read_only.dart';
import 'package:frappe_app/form/controls/text.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/model/config.dart';
import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/services/api/api.dart';
import 'package:frappe_app/utils/helpers.dart';
import 'package:frappe_app/widgets/custom_expansion_tile.dart';
import 'package:frappe_app/widgets/section.dart';

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
  required Map doc,
  OnControlChanged? onControlChanged,
  bool decorateControl = true,
  List<DoctypeField>? dependentFields,
}) {
  Widget control;

  switch (field.fieldtype) {
    case "Link":
      {
        control = LinkField(
          doctypeField: field,
          dependentFields: dependentFields,
          doc: doc,
          onControlChanged: onControlChanged,
        );
      }
      break;

    case "Dynamic Link":
      {
        control = DynamicLink(
          doctypeField: field,
          doc: doc,
          onControlChanged: onControlChanged,
        );
      }
      break;

    case "Autocomplete":
      {
        control = AutoComplete(
          doctypeField: field,
          dependentFields: dependentFields,
          doc: doc,
          onControlChanged: onControlChanged,
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
          doc: doc,
          dependentFields: dependentFields,
          doctypeField: field,
          onControlChanged: onControlChanged,
        );
      }
      break;

    case "MultiSelect":
      {
        control = MultiSelect(
          doctypeField: field,
          doc: doc,
          onControlChanged: onControlChanged,
        );
      }
      break;

    case "Table MultiSelect":
      {
        control = MultiSelect(
          doctypeField: field,
          doc: doc,
          onControlChanged: onControlChanged,
        );
      }
      break;

    case "Small Text":
      {
        control = SmallText(
          doctypeField: field,
          doc: doc,
        );
      }
      break;

    case "Text":
      {
        control = ControlText(
          doctypeField: field,
          doc: doc,
        );
      }
      break;

    case "Data":
      {
        control = Data(
          doc: doc,
          doctypeField: field,
        );
      }
      break;

    case "Read Only":
      {
        control = ReadOnly(
          doc: doc,
          doctypeField: field,
        );
      }
      break;

    case "Check":
      {
        control = Check(
          dependentFields: dependentFields,
          doctypeField: field,
          doc: doc,
          onControlChanged: onControlChanged,
        );
      }
      break;

    case "Text Editor":
      {
        control = TextEditor(
          doctypeField: field,
          doc: doc,
        );
      }
      break;

    case "Datetime":
      {
        control = DatetimeField(
          doctypeField: field,
          doc: doc,
        );
      }
      break;

    case "Float":
    case "Percent":
      {
        control = Float(
          doctypeField: field,
          doc: doc,
        );
      }
      break;

    case "Currency":
      {
        control = Currency(
          doctypeField: field,
          doc: doc,
        );
      }
      break;

    case "Int":
      {
        control = Int(
          doctypeField: field,
          doc: doc,
        );
      }
      break;

    case "Time":
      {
        control = Time(
          doctypeField: field,
          doc: doc,
        );
      }
      break;

    case "Date":
      {
        control = Date(
          doctypeField: field,
          doc: doc,
        );
      }
      break;

    // case "Signature":
    //   {
    //     control = customSignature.Signature(
    //       doc: doc,
    //       doctypeField: field,
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
      field: field,
    );
  } else {
    return Padding(
      padding: Palette.fieldPadding,
      child: control,
    );
  }
}

Widget buildDecoratedControl({
  required Widget control,
  required DoctypeField field,
}) {
  return Padding(
    padding: Palette.fieldPadding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: [
            if (field.fieldtype != "Check")
              Padding(
                padding: Palette.labelPadding,
                child: Text(
                  field.label ?? "",
                  style: TextStyle(
                    color: FrappePalette.grey[700],
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ),
            SizedBox(width: 4),
            if (field.reqd == 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  '*',
                  style: TextStyle(
                    color: FrappePalette.red,
                  ),
                ),
              ),
          ],
        ),
        control
      ],
    ),
  );
}

List<Widget> generateLayout({
  required List<DoctypeField> fields,
  required OnControlChanged onControlChanged,
  required Map doc,
}) {
  List<Widget> collapsibles = [];
  List<Widget> widgets = [];
  List<Widget> sections = [];
  var fieldDependentFieldsMapping = {};
  var parentFieldNames = [];

  List<String> collapsibleLabels = [];
  List<String> sectionLabels = [];

  var isCollapsible = false;
  var isSection = false;

  int cIdx = 0;
  int sIdx = 0;

  var dependentFields = fields
      .where(
        (element) => element.fetchFrom != null || element.dependsOn != null,
      )
      .toList();

  dependentFields.forEach((dependentField) {
    var parentField;
    if (dependentField.fetchFrom != null) {
      parentField = dependentField.fetchFrom!.split('.')[0];
      parentFieldNames.add(parentField);
    }
    if (dependentField.dependsOn != null) {
      if (dependentField.dependsOn!.startsWith("eval:doc")) {
        parentField =
            dependentField.dependsOn!.split("doc.")[1].split("==")[0].trim();
        parentFieldNames.add(parentField);
      } else {
        parentField = dependentField.dependsOn!;
      }
    }
    if (fieldDependentFieldsMapping[parentField] == null) {
      fieldDependentFieldsMapping[parentField] = [dependentField];
    } else {
      fieldDependentFieldsMapping[parentField].add(dependentField);
    }
  });

  parentFieldNames = parentFieldNames.toSet().toList();

  fields.forEach(
    (field) {
      var attachListener = false;
      if (parentFieldNames.contains(field.fieldname)) {
        attachListener = true;
      }

      var fieldVisibility = true;

      if (field.dependsOn != null) {
        fieldVisibility = dependsOn(
          doc: doc,
          field: field,
        );
      }

      var controlWidget = Visibility(
        visible: fieldVisibility,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
          ),
          child: makeControl(
            field: field,
            doc: doc,
            onControlChanged: attachListener ? onControlChanged : null,
            dependentFields: fieldDependentFieldsMapping[field.fieldname] ?? [],
          ),
        ),
      );

      // TODO handle in better way
      var controlWidget2 = Visibility(
        visible: fieldVisibility,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
          ),
          child: makeControl(
            field: field,
            doc: doc,
            onControlChanged: attachListener ? onControlChanged : null,
            dependentFields: fieldDependentFieldsMapping[field.fieldname] ?? [],
          ),
        ),
      );

      if (field.fieldtype == "Section Break") {
        if (sections.length > 0) {
          var sSplit = sectionLabels[sIdx].split("@@");
          var sectionLabel = sSplit[0];
          var sectionVisibility = sSplit[1];
          widgets.add(
            Visibility(
              visible: sectionVisibility == "true",
              child: sectionLabel != ''
                  ? Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10.0,
                      ),
                      child: ListTileTheme(
                        tileColor: Colors.white,
                        child: CustomExpansionTile(
                          maintainState: true,
                          initiallyExpanded: true,
                          title: Text(
                            sectionLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          children: [
                            Container(
                              color: Colors.white,
                              child: Column(
                                children: [...sections],
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10.0,
                      ),
                      child: Section(
                        title: sectionLabel,
                        children: [...sections],
                      ),
                    ),
            ),
          );

          sIdx += 1;
          sections.clear();
        } else if (collapsibles.length > 0) {
          var cSplit = collapsibleLabels[cIdx].split("@@");
          var collapsibleLabel = cSplit[0];
          var collapsibleVisibility = cSplit[1];
          widgets.add(
            Visibility(
              visible: collapsibleVisibility == "true",
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 10.0,
                ),
                child: ListTileTheme(
                  tileColor: Colors.white,
                  child: CustomExpansionTile(
                    maintainState: true,
                    title: Text(
                      collapsibleLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    children: [
                      Container(
                          color: Colors.white,
                          child: Column(
                            children: [...collapsibles],
                          ))
                    ],
                  ),
                ),
              ),
            ),
          );
          cIdx += 1;
          collapsibles.clear();
        }

        if (field.collapsible == 1) {
          var cLabel = "${field.label!}@@$fieldVisibility";
          isSection = false;
          isCollapsible = true;
          collapsibleLabels.add(cLabel);
        } else {
          var sLabel =
              "${field.label != null ? field.label! : ''}@@$fieldVisibility";
          isCollapsible = false;
          isSection = true;
          sectionLabels.add(sLabel);
        }
      } else if (isSection) {
        var firstField = sections.isEmpty;
        if (firstField) {
          sections.add(
            controlWidget,
          );
        } else {
          sections.add(
            controlWidget2,
          );
        }
      } else if (isCollapsible) {
        collapsibles.add(controlWidget);
      } else {
        widgets.add(controlWidget);
      }
    },
  );

  if (sections.length > 0) {
    var sSplit = sectionLabels[sIdx].split("@@");
    var sectionLabel = sSplit[0];
    var sectionVisibility = sSplit[1];
    widgets.add(
      Visibility(
        visible: sectionVisibility == "true",
        child: sectionLabel != ''
            ? Padding(
                padding: const EdgeInsets.only(
                  bottom: 10.0,
                ),
                child: ListTileTheme(
                  tileColor: Colors.white,
                  child: CustomExpansionTile(
                    maintainState: true,
                    initiallyExpanded: true,
                    title: Text(
                      sectionLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    children: [
                      Container(
                        color: Colors.white,
                        child: Column(
                          children: [...sections],
                        ),
                      )
                    ],
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                ),
                child: Section(
                  title: sectionLabel,
                  children: [...sections],
                ),
              ),
      ),
    );

    sIdx += 1;
    sections.clear();
  }

  if (collapsibles.length > 0) {
    var cSplit = collapsibleLabels[cIdx].split("@@");
    var collapsibleLabel = cSplit[0];
    var collapsibleVisibility = cSplit[1];
    widgets.add(
      Visibility(
        visible: collapsibleVisibility == "true",
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 10,
          ),
          child: ListTileTheme(
            tileColor: Colors.white,
            child: CustomExpansionTile(
              maintainState: true,
              title: Text(
                collapsibleLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              children: [
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [...collapsibles],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
    cIdx += 1;
    collapsibles.clear();
  }

  return widgets;
}

bool dependsOn({
  required Map doc,
  required DoctypeField field,
}) {
  var formValEncoded = jsonEncode(doc);
  if (field.dependsOn!.startsWith("eval")) {
    var docProperty = field.dependsOn!.split("eval:")[1];
    var evalResult = executeJS(jsString: """
            var doc = $formValEncoded;
            $docProperty
            """);

    if (evalResult == 1 || evalResult == true) {
      return true;
    } else {
      return false;
    }
  } else {
    return doc[field.dependsOn] == 1;
  }
}
