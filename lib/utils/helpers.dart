import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/utils/backend_service.dart';
import 'package:frappe_app/widgets/section.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/palette.dart';
import '../form/controls/link_field.dart';
import '../form/controls/multi_select.dart';
import '../utils/enums.dart';
import '../main.dart';
import '../app.dart';
import './http.dart';
import '../widgets/custom_expansion_tile.dart';

logout(context) async {
  var cookieJar = await getCookiePath();

  cookieJar.delete(uri);

  localStorage.setBool('isLoggedIn', false);

  Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => FrappeApp(),
      ),
      (Route<dynamic> route) => false);
}

Future processData(
  String doctype,
  context,
) async {
  var meta = await BackendService(context).getDoctype(doctype);

  List metaFields = meta["docs"][0]["fields"];

  metaFields.forEach((field) {
    meta["docs"][0]["_field${field["fieldname"]}"] = true;
    if (field["fieldtype"] == "Select") {
      if (field["hidden"] != 1) {
        field["options"] =
            field["options"] != null ? field["options"].split('\n') : [];
      }
    }
  });

  localStorage.setString('${doctype}Meta', json.encode(meta));

  return meta;
}

Widget buildDecoratedWidget(Widget fieldWidget, bool withLabel,
    [String label = ""]) {
  if (withLabel) {
    return Padding(
      padding: Palette.fieldPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: Palette.labelPadding,
            child: Text(
              label,
              style: Palette.secondaryTxtStyle,
            ),
          ),
          fieldWidget
        ],
      ),
    );
  } else {
    return Padding(
      padding: Palette.fieldPadding,
      child: fieldWidget,
    );
  }
}

Widget makeControl(Map field,
    [val, bool withLabel = true, bool editMode = true]) {
  Widget value;
  List<String Function(dynamic)> validators = [];

  if (field["reqd"] == 1) {
    validators.add(FormBuilderValidators.required());
  }

  switch (field["fieldtype"]) {
    case "Link":
      {
        value = buildDecoratedWidget(
            LinkField(
              key: Key(val),
              fillColor: Palette.fieldBgColor,
              allowClear: editMode,
              validators: validators,
              attribute: field["fieldname"],
              doctype: field["options"],
              hint: !withLabel ? field["label"] : null,
              refDoctype: field["refDoctype"],
              value: val,
            ),
            withLabel,
            field["label"]);
      }
      break;

    case "Select":
      {
        value = buildDecoratedWidget(
            FormBuilderDropdown(
              key: Key(val),
              initialValue: val,
              allowClear: editMode,
              attribute: field["fieldname"],
              hint: !withLabel ? Text(field["label"]) : null,
              decoration: Palette.formFieldDecoration(
                withLabel,
                field["label"],
              ),
              validators: validators,
              items: field["options"].map<DropdownMenuItem>((option) {
                return DropdownMenuItem(
                  value: option,
                  child: option != null
                      ? Text(
                          '$option',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        )
                      : Text(''),
                );
              }).toList(),
            ),
            withLabel,
            field["label"]);
      }
      break;

    case "MultiSelect":
      {
        if (val != null) {
          val = [
            {
              "value": val,
              "description": val,
            }
          ];
        }

        value = buildDecoratedWidget(
            MultiSelect(
              attribute: field["fieldname"],
              hint: field["label"],
              val: val != null ? val : [],
            ),
            withLabel,
            field["label"]);
      }
      break;

    case "Small Text":
      {
        value = buildDecoratedWidget(
            FormBuilderTextField(
              initialValue: val,
              attribute: field["fieldname"],
              decoration: Palette.formFieldDecoration(
                withLabel,
                field["label"],
              ),
              validators: [
                FormBuilderValidators.required(),
              ],
            ),
            withLabel,
            field["label"]);
      }
      break;

    case "Data":
      {
        value = buildDecoratedWidget(
            FormBuilderTextField(
              initialValue: val,
              key: Key(val),
              attribute: field["fieldname"],
              decoration: Palette.formFieldDecoration(
                withLabel,
                field["label"],
              ),
              validators: validators,
            ),
            withLabel,
            field["label"]);
      }
      break;

    case "Check":
      {
        value = buildDecoratedWidget(
            FormBuilderCheckbox(
              leadingInput: true,
              key: Key(val.toString()),
              attribute: field["fieldname"],
              label: Text(field["label"]),
              decoration: Palette.formFieldDecoration(
                withLabel,
                field["label"],
              ),
              validators: validators,
            ),
            false);
      }
      break;

    case "Text Editor":
      {
        value = buildDecoratedWidget(
            FormBuilderTextField(
                maxLines: 10,
                initialValue: val,
                attribute: field["fieldname"],
                decoration: Palette.formFieldDecoration(
                  withLabel,
                  field["label"],
                ),
                validators: validators),
            withLabel,
            field["label"]);
      }
      break;

    case "Datetime":
      {
        value = buildDecoratedWidget(
            FormBuilderDateTimePicker(
              key: Key(val),
              valueTransformer: (val) {
                return val != null ? val.toIso8601String() : null;
              },
              resetIcon: editMode ? Icon(Icons.close) : null,
              initialTime: null,
              initialValue: parseDate(val),
              attribute: field["fieldname"],
              decoration: Palette.formFieldDecoration(
                withLabel,
                field["label"],
              ),
              validators: validators,
            ),
            withLabel,
            field["label"]);
      }
      break;

    case "Float":
    case "Int":
      {
        value = buildDecoratedWidget(
            FormBuilderTextField(
              key: Key(val.toString()),
              initialValue: val != null ? val.toString() : null,
              keyboardType: TextInputType.number,
              attribute: field["fieldname"],
              decoration: Palette.formFieldDecoration(
                withLabel,
                field["label"],
              ),
              validators: validators,
            ),
            withLabel,
            field["label"]);
      }
      break;

    case "Time":
      {
        value = buildDecoratedWidget(
            FormBuilderDateTimePicker(
              key: Key(val),
              inputType: InputType.time,
              valueTransformer: (val) {
                return val != null ? val.toIso8601String() : null;
              },
              keyboardType: TextInputType.number,
              attribute: field["fieldname"],
              decoration: Palette.formFieldDecoration(
                withLabel,
                field["label"],
              ),
              validators: validators,
            ),
            withLabel,
            field["label"]);
      }
      break;

    case "Date":
      {
        value = buildDecoratedWidget(
            FormBuilderDateTimePicker(
              key: Key(val),
              inputType: InputType.date,
              valueTransformer: (val) {
                return val != null ? val.toIso8601String() : null;
              },
              initialValue: parseDate(val),
              keyboardType: TextInputType.number,
              attribute: field["fieldname"],
              decoration: Palette.formFieldDecoration(
                withLabel,
                field["label"],
              ),
              validators: validators,
            ),
            withLabel,
            field["label"]);
      }
      break;

    default:
      value = Container();
      break;
  }
  return value;
}

downloadFile(String fileUrl) async {
  await _checkPermission();

  final absoluteUrl = getAbsoluteUrl(fileUrl);
  var downloadsPath;

  // TODO
  if (Platform.isAndroid) {
    downloadsPath = '/storage/emulated/0/Download/';
  } else if (Platform.isIOS) {
    final Directory downloadsDirectory =
        await getApplicationDocumentsDirectory();
    downloadsPath = downloadsDirectory.path;
  }

  await FlutterDownloader.enqueue(
    headers: {
      HttpHeaders.cookieHeader: await getCookies(),
    },
    url: absoluteUrl,
    savedDir: downloadsPath,
    showNotification:
        true, // show download progress in status bar (for Android)
    openFileFromNotification:
        true, // click on notification to open downloaded file (for Android)
  );
}

Future<bool> _checkPermission() async {
  if (Platform.isAndroid) {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
        return true;
      }
    } else {
      return true;
    }
  } else {
    return true;
  }
  return false;
}

String toTitleCase(String str) {
  return str
      .replaceAllMapped(
          RegExp(
              r'[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+'),
          (Match m) =>
              "${m[0][0].toUpperCase()}${m[0].substring(1).toLowerCase()}")
      .replaceAll(RegExp(r'(_|-)+'), ' ');
}

void showSnackBar(String txt, context) {
  Scaffold.of(context).showSnackBar(
    SnackBar(
      content: Text(txt),
    ),
  );
}

List<Widget> generateLayout({
  @required List fields,
  @required ViewType viewType,
  bool editMode = true,
  bool withLabel = true,
}) {
  List<Widget> collapsibles = [];
  List<Widget> sections = [];
  List<Widget> widgets = [];

  List<String> collapsibleLabels = [];
  List<String> sectionLabels = [];

  bool isCollapsible = false;
  bool isSection = false;

  int cIdx = 0;
  int sIdx = 0;

  fields.forEach((field) {
    var val = field["_current_val"] ?? field["default"];

    if (val == '__user') {
      val = Uri.decodeFull(localStorage.getString('userId'));
    }

    if (field["fieldtype"] == "Section Break") {
      if (sections.length > 0) {
        var sectionVisibility = sections.any((element) {
          if (element is Visibility) {
            return element.visible == true;
          } else {
            return true;
          }
        });

        widgets.add(
          Visibility(
            visible: sectionVisibility,
            child: sectionLabels[sIdx] != ''
                ? ListTileTheme(
                    contentPadding: EdgeInsets.all(0),
                    child: CustomExpansionTile(
                      maintainState: true,
                      initiallyExpanded: true,
                      title: Text(
                        sectionLabels[sIdx].toUpperCase(),
                        style: Palette.secondaryTxtStyle,
                      ),
                      children: [...sections],
                    ),
                  )
                : Section(
                    title: sectionLabels[sIdx],
                    children: [...sections],
                  ),
          ),
        );

        sIdx += 1;
        sections.clear();
      } else if (collapsibles.length > 0) {
        var sectionVisibility = collapsibles.any((element) {
          if (element is Visibility) {
            return element.visible == true;
          } else {
            return true;
          }
        });
        widgets.add(
          Visibility(
            visible: sectionVisibility,
            child: ListTileTheme(
              contentPadding: EdgeInsets.all(0),
              child: CustomExpansionTile(
                maintainState: true,
                title: Text(
                  collapsibleLabels[cIdx].toUpperCase(),
                  style: Palette.secondaryTxtStyle,
                ),
                children: [...collapsibles],
              ),
            ),
          ),
        );
        cIdx += 1;
        collapsibles.clear();
      }

      if (field["collapsible"] == 1) {
        isSection = false;
        isCollapsible = true;
        collapsibleLabels.add(field["label"]);
      } else {
        isCollapsible = false;
        isSection = true;
        sectionLabels
            .add(field["label"] != null ? field["label"].toUpperCase() : '');
      }
    } else if (isCollapsible) {
      if (viewType == ViewType.form) {
        collapsibles.add(Visibility(
          visible: editMode ? true : val != null && val != '',
          child: makeControl(field, val, withLabel, editMode),
        ));
      } else {
        collapsibles.add(
          makeControl(field, val, withLabel, editMode),
        );
      }
    } else if (isSection) {
      if (viewType == ViewType.form) {
        sections.add(Visibility(
          visible: editMode ? true : val != null && val != '',
          child: makeControl(field, val, withLabel, editMode),
        ));
      } else {
        sections.add(
          makeControl(field, val, withLabel, editMode),
        );
      }
    } else {
      if (viewType == ViewType.form) {
        widgets.add(Visibility(
          visible: editMode ? true : val != null && val != '',
          child: makeControl(field, val, withLabel, editMode),
        ));
      } else {
        widgets.add(
          makeControl(field, val, withLabel, editMode),
        );
      }
    }
  });

  return widgets;
}

DateTime parseDate(val) {
  if (val == null) {
    return null;
  } else if (val == "Today") {
    return DateTime.now();
  } else {
    return DateTime.parse(val);
  }
}

List generateFieldnames(String doctype, Map meta) {
  var fields = [
    'name',
    'modified',
    '_assign',
    '_seen',
    '_liked_by',
    '_comments',
  ];

  if (meta["title_field"] != null) {
    fields.add(meta["title_field"]);
  }

  if (hasField(meta, 'status')) {
    fields.add('status');
  } else {
    fields.add('docstatus');
  }

  var transformedFields = fields.map((field) {
    return "`tab$doctype`.`$field`";
  }).toList();

  return transformedFields;
}

String getInitials(String txt) {
  List<String> names = txt.split(" ");
  String initials = "";
  int numWords = 2;

  if (names.length < numWords) {
    numWords = names.length;
  }
  for (var i = 0; i < numWords; i++) {
    initials += names[i] != '' ? '${names[i][0].toUpperCase()}' : "";
  }
  return initials;
}

bool hasField(Map meta, String fieldName) {
  return meta.containsKey('_field$fieldName');
}

bool isSubmittable(Map meta) {
  return meta["is_submittable"] == 1;
}
