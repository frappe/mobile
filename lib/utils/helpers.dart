import 'dart:io';

import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/form/link_field.dart';
import 'package:frappe_app/form/multi_select.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/response_models.dart';
import '../app.dart';
import './http.dart';

logout(context) async {
  var cookieJar = await getCookiePath();

  cookieJar.delete(Uri(
      scheme: "https",
      // port: int.parse("8000", radix: 16),
      host: "version13beta.erpnext.com"));

  SharedPreferences localStorage = await SharedPreferences.getInstance();
  localStorage.setBool('isLoggedIn', false);

  // Navigator.of(context).pushReplacementNamed('/login');

  Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => FrappeApp(),
      ),
      (Route<dynamic> route) => false);
}

getMeta(doctype) async {
  var queryParams = {'doctype': doctype};

  final response2 = await dio.get('/method/frappe.desk.form.load.getdoctype',
      queryParameters: queryParams);

  if (response2.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return DioGetMetaResponse.fromJson(response2.data);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

Future<Map> processData(Map data, bool metaRequired) async {
  // layout
  data["fieldnames"] = [];
  if (!metaRequired) {
    data["fields"].forEach((field) {
      if (field["in_list_view"] != null) {
        data["fieldnames"]
            .add("`tab${data["doctype"]}`.`${field["fieldname"]}`");
      }
    });
  } else {
    var meta = await getMeta(data["doctype"]);

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
        value = LinkFormField(
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
        value = FormBuilderDropdown(
          onChanged: callback,
          initialValue: val,
          attribute: widget["fieldname"],
          decoration: InputDecoration(
            labelText: widget["hint"],
          ),
          // hint: Text(widget["hint"]),
          validators: [FormBuilderValidators.required()],
          items: widget["options"]
              .map<DropdownMenuItem>((option) => DropdownMenuItem(
                    value: option,
                    child: Text('$option'),
                  ))
              .toList(),
        );
      }
      break;

    case "MultiSelect":
      {
        value = MultiSelectFormField(
          attribute: widget["fieldname"],
          hint: widget["label"],
          callback: callback,
        );
      }
      break;

    case "Small Text":
      {
        value = FormBuilderTextField(
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

downloadFile(String fileUrl) async {
  await _checkPermission();

  final absoluteUrl = getAbsoluteUrl(fileUrl);

  // TODO
  final Directory downloadsDirectory =
      await DownloadsPathProvider.downloadsDirectory;
  final String downloadsPath = downloadsDirectory.path;

  await FlutterDownloader.enqueue(
    headers: await getCookiesWithHeader(),
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
