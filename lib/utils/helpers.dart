import 'package:flutter/material.dart';
import 'package:support_app/utils/response_models.dart';
import 'package:support_app/widgets/link_field.dart';
import 'package:support_app/widgets/select_field.dart';

import '../main.dart';
import 'http.dart';

logout(context) async {
  var cookieJar = await cookie();
  cookieJar.delete(Uri(
      scheme: "http",
      port: int.parse("8000", radix: 16),
      host: "erpnext.dev2"));

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
          builder: (context) => MyApp(),
        ), (Route<dynamic> route) => false);
}

getMeta(doctype) async {
  var queryParams = {
    'doctype': doctype
  };

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

Future<Map> processData(Map data) async {
  var meta = await getMeta(data["doctype"]);
  
  List fields = meta.values.docs[0]["fields"];
  
  data["grids"].forEach((g) {
    if(g["widget"]["fieldtype"] == "Select") {
      var fi = fields.where((f) => f["fieldtype"] == 'Select' && f["fieldname"] == g["widget"]["fieldname"]).toList();
      g["widget"]["options"] = fi[0]["options"].split('\n');
    }
  });

  return data;
}

Widget generateChildWidget(Map widget, val, callback) {
  Widget value;

  switch (widget["fieldtype"]) {
    case "Link":
      {
        value = LinkField(
            doctype: widget["doctype"],
            hint: Text(widget["hint"]),
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
          onChanged: callback
        );
      }
      break;
  }
  return value;
}
