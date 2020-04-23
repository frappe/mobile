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
        value = LinkField(
          hint: widget["fieldname"],
          req_type: 'get_contact_list',
          onSuggestionSelected: callback,
          value: val,
        );
      }
      break;

    case "Small Text": {
      value = TextField(
        controller: widget["controller"],
        decoration: InputDecoration(hintText: widget["hint"]),
      );
    }
    break;

    case "Check": {
      if(val == null) {
        val = false;
      }
      value = CheckboxListTile(
        title: Text(widget["hint"]),
        value: val,
        onChanged: callback,
      );
    }
    break;
  }
  return value;
}
