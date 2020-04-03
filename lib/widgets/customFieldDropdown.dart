import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:support_app/utils/http.dart';

class Response {
  final String options;

  Response({this.options});

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      options: json['options']
    );
  }
}

class DioResponse {
  final List<Response> values;
  final String error;

  DioResponse(this.values, this.error);

  DioResponse.fromJson(Map<String, dynamic> json)
      : values = (json["data"] as List)
            .map((i) => new Response.fromJson(i))
            .toList(),
        error = "";

  DioResponse.withError(String errorValue)
      : values = List(),
        error = errorValue;
}

Future<DioResponse> fetchCustomField(fieldName, doctype) async {
  var queryParams = {
    "filters": jsonEncode([["fieldname", "=", fieldName], ["dt", "=", doctype]]),
    "fields": jsonEncode(["options"])
  };

  final response2 = await dio.get('/resource/Custom Field', queryParameters: queryParams);
  if (response2.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return DioResponse.fromJson(response2.data);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class CustomFieldDropdown extends StatefulWidget {
  final fieldName;
  final doctype;
  final value;
  final hint;
  final Function onChanged;

  CustomFieldDropdown({this.value, this.onChanged, @required this.fieldName, @required this.doctype, this.hint});

  @override
  _CustomFieldDropdownState createState() => _CustomFieldDropdownState();
}

class _CustomFieldDropdownState extends State<CustomFieldDropdown> {
  String dropdownVal;
  Future<DioResponse> futureCustomField;

  @override
  void initState() {
    super.initState();
    futureCustomField = fetchCustomField(widget.fieldName, widget.doctype);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DioResponse>(
        future: futureCustomField,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var options = snapshot.data.values[0].options.split('\n');
            print('here');
            return DropdownButton(
              value: widget.value,
              onChanged: (dynamic newVal) {
                widget.onChanged(newVal);
              },
              hint: Text(widget.hint),
              items: options.map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return CircularProgressIndicator();
        });
  }
}
