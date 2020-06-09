import 'dart:io';

// import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/palette.dart';
import '../form/link_field2.dart';
import '../form/multi_select2.dart';
import '../utils/enums.dart';
import '../main.dart';
import '../utils/response_models.dart';
import '../app.dart';
import './http.dart';

logout(context) async {
  var cookieJar = await getCookiePath();

  cookieJar.delete(uri);

  localStorage.setBool('isLoggedIn', false);

  // Navigator.of(context).pushReplacementNamed('/login');

  Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => FrappeApp(),
      ),
      (Route<dynamic> route) => false);
}

getMeta(doctype, context) async {
  var queryParams = {'doctype': doctype};

  final response2 = await dio.get(
    '/method/frappe.desk.form.load.getdoctype',
    queryParameters: queryParams,
    options: Options(
      validateStatus: (status) {
        return status < 500;
      },
    ),
  );

  if (response2.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return DioGetMetaResponse.fromJson(response2.data);
  } else if (response2.statusCode == 403) {
    logout(context);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

Future<Map> processData(Map data, bool metaRequired,
    {ViewType viewType, context}) async {
  // layout
  data["fieldnames"] = [];
  if (!metaRequired) {
    data["fields"].forEach((field) {
      if (field["in_list_view"] != null) {
        data["fieldnames"]
            .add("`tab${data["doctype"]}`.`${field["fieldname"]}`");
      }
    });
    data["fieldnames"].add("`tab${data["doctype"]}`.`${"modified"}`");
  } else {
    var meta = await getMeta(data["doctype"], context);

    List metaFields = meta.values.docs[0]["fields"];

    data["fields"].forEach((field) {
      if (field["fieldtype"] == "Select") {
        var fi = metaFields.firstWhere(
            (metaField) =>
                metaField["fieldtype"] == 'Select' &&
                metaField["fieldname"] == field["fieldname"] &&
                metaField["is_custom_field"] == field["is_custom_field"],
            orElse: () => null);

        if (fi != null) {
          field["options"] = fi["options"].split('\n');
        } else {
          field["skip_field"] = true;
        }

        if (viewType == ViewType.filter) {
          field["options"].insert(0, null);
        }
      }
    });
  }

  return data;
}

Widget generateChildWidget(Map widget, [val, callback]) {
  // rename makeControl
  Widget value;

  switch (widget["fieldtype"]) {
    case "Link":
      {
        value = LinkField2(
            attribute: widget["fieldname"],
            doctype: widget["doctype"],
            hint: widget["hint"],
            refDoctype: widget["refDoctype"],
            value: val,
            callback: callback);
      }
      break;

    case "Select":
      {
        value = Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget["hint"].toUpperCase(), style: Palette.labelStyle),
              FormBuilderDropdown(
                onChanged: callback,
                initialValue: val,
                attribute: widget["fieldname"],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Palette.fieldBgColor,
                  enabledBorder: InputBorder.none,
                ),
                // validators: [FormBuilderValidators.required()],
                items: widget["options"].map<DropdownMenuItem>((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: option != null ? Text('$option') : Text(''),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }
      break;

    case "MultiSelect":
      {
        if (val != null) {
          val = [Contact(value: val)];
        }

        value = MultiSelect2(
          attribute: widget["fieldname"],
          hint: widget["label"],
          val: val != null ? val : [],
        );
      }
      break;

    case "Small Text":
      {
        value = FormBuilderTextField(
          initialValue: val,
          onChanged: callback,
          attribute: widget["fieldname"],
          decoration: InputDecoration(hintText: widget["hint"]),
          validators: [
            FormBuilderValidators.required(),
          ],
        );
      }
      break;

    case "Check":
      {
        value = FormBuilderCheckbox(
          leadingInput: true,
          attribute: widget["fieldname"],
          label: Text(widget["hint"]),
          validators: [],
        );
      }
      break;

    case "Text Editor":
      {
        value = FormBuilderTextField(
          maxLines: 10,
          onChanged: callback,
          attribute: widget["fieldname"],
          decoration: InputDecoration(hintText: widget["hint"]),
          validators: [
            FormBuilderValidators.required(),
          ],
        );
      }
  }
  return value;
}

// Widget generateLayout(fields) {
//   var layout = [];
//   var colBreak = true;
//   var rows = [];
//   var row1Count = 0;
//   var row2Count = 0;
//   var collapsible;

//   // 1 section can contain one colbreak

//   fields.asMap().forEach((index, field) {

//     if (field["fieldtype"] == "Section Break") {
//       collapsible = false;
//       colBreak = false;
//       row1Count = 0;
//       row2Count = 0;
//       if(field["collapsible"] == 1) {
//         collapsible = true;
//       }
//       rows.add('section');
//       // generate section
//     } else if (field["fieldtype" == "Column Break"]) {
//       if(colBreak == true) {
//         // throw error
//       }
//       colBreak = true;
//       row2Count = row1Count;
//     } else {
//       if(colBreak == true) {
//         if(collapsible = true) {
//           rows.add(generateCollapsible(fields.sublist(index+1)));
//         }
//         rows[row1Count - row2Count].add('widget2');
//         row2Count -= 1;
//       } else {
//         row1Count += 1;
//         rows.add(['widget']);
//       }
//     }

//   });

//   // return Column(children: <Widget>[
//   //   Row(children: rows)
//   // ],);
// }

// Widget generateCollapsible(fields) {
//   var collapsibleFields = fields.takeWhile((field) {
//     return field["fieldtype"] != 'Section Break';
//   });

//   // wrap in collapsible
// }

// downloadFile(String fileUrl) async {
//   await _checkPermission();

//   final absoluteUrl = getAbsoluteUrl(fileUrl);

//   // TODO
//   final Directory downloadsDirectory =
//       await DownloadsPathProvider.downloadsDirectory;
//   final String downloadsPath = downloadsDirectory.path;

//   await FlutterDownloader.enqueue(
//     headers: await getCookiesWithHeader(),
//     url: absoluteUrl,
//     savedDir: downloadsPath,
//     showNotification:
//         true, // show download progress in status bar (for Android)
//     openFileFromNotification:
//         true, // click on notification to open downloaded file (for Android)
//   );
// }

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

Color setStatusColor(String status) {
  Color _color;
  if (status == 'Open') {
    _color = Color(0xffffa00a);
  } else if (status == 'Replied') {
    _color = Color(0xffb8c2cc);
  } else if (status == 'Hold') {
    _color = Colors.redAccent[400];
  } else if (status == 'Closed') {
    _color = Color(0xff98d85b);
  }
  return _color;
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
