import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:support_app/utils/http.dart';

import '../utils/toJson.dart';

Future<DioResponse> fetchPriority() async {
  var queryParams = {
    'txt': '',
    'doctype': 'Issue Priority',
    'reference_doctype': 'Issue',
    'ignore_user_permissions': 0
  };

  final response2 = await dio.post('/method/frappe.desk.search.search_link',
      data: queryParams,
      options: Options(contentType: Headers.formUrlEncodedContentType));
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

class PriorityDropdown extends StatefulWidget {
  final value;
  final Function onChanged;

  PriorityDropdown({this.value, this.onChanged});

  @override
  _PriorityDropdownState createState() => _PriorityDropdownState();
}

class _PriorityDropdownState extends State<PriorityDropdown> {
  String dropdownVal;
  Future<DioResponse> futurePriority;

  @override
  void initState() {
    super.initState();
    futurePriority = fetchPriority();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DioResponse>(
        future: futurePriority,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DropdownButton(
              value: widget.value,
              onChanged: (dynamic newVal) {
                widget.onChanged(newVal);
              },
              hint: Text('Priority'),
              items: snapshot.data.values.map((value) {
                return DropdownMenuItem(
                  value: value.value,
                  child: Text(value.value),
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
