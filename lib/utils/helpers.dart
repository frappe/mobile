import 'dart:io';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support_app/utils/response_models.dart';
import 'package:support_app/widgets/link_field.dart';
import 'package:support_app/widgets/multi-select.dart';
import 'package:support_app/widgets/select_field.dart';

import '../app.dart';
import 'http.dart';

logout(context) async {
  var cookieJar = await cookie();
  // cookieJar.delete(Uri(
  //     scheme: "http",
  //     port: int.parse("8000", radix: 16),
  //     host: "erpnext.dev2"));
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
        builder: (context) => MyApp(),
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

    List meta_fields = meta.values.docs[0]["fields"];

    data["fields"].forEach((field) {
      if (field["fieldtype"] == "Select") {
        var fi = meta_fields.firstWhere(
            (meta_field) =>
                meta_field["fieldtype"] == 'Select' &&
                meta_field["fieldname"] == field["fieldname"] &&
                meta_field["is_custom_field"] == field["is_custom_field"],
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

Widget generateChildWidget(Map widget, val, callback) {
  // rename makeControl
  Widget value;

  switch (widget["fieldtype"]) {
    case "Link":
      {
        value = LinkField(
            doctype: widget["doctype"],
            hint: widget["hint"],
            refDoctype: widget["refDoctype"],
            value: val,
            onSuggestionSelected: callback);
      }
      break;

    case "Select":
      {
        value = SelectField(
            options: widget["options"],
            value: val,
            hint: Text(widget["hint"]),
            onChanged: callback);
      }
      break;

    case "MultiSelect":
      {
        value = MultiSelect(
          hint: widget["label"],
          onSuggestionSelected: callback,
          value: val,
        );
      }
      break;

    case "Small Text":
      {
        value = TextField(
          onChanged: callback,
          decoration: InputDecoration(hintText: widget["hint"]),
        );
      }
      break;

    case "Check":
      {
        if (val == null) {
          val = false;
        }
        value = CheckboxListTile(
          title: Text(widget["hint"]),
          value: val,
          onChanged: callback,
        );
      }
      break;

    case "Text Editor":
    {
      value = TextField(
          onChanged: callback,
          decoration: InputDecoration(hintText: widget["hint"]),
          maxLines: 10,
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
  var cookieJar = await cookie();
  // var cookies = CookieManager.getCookies(cookieJar);

  var cookies = cookieJar.loadForRequest(Uri(
      scheme: "https",
      // port: int.parse("8000", radix: 16),
      host: "version13beta.erpnext.com"));

  print(cookies);

  var c= CookieManager.getCookies(cookies);

  final url = "$baseUrl$fileUrl";
  var encoded = Uri.encodeFull(url);
  final Directory downloadsDirectory =
      await DownloadsPathProvider.downloadsDirectory;
  final String downloadsPath = downloadsDirectory.path;
  await FlutterDownloader.enqueue(
    headers: {HttpHeaders.cookieHeader:c},
    url: encoded,
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
