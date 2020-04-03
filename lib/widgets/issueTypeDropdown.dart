import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:support_app/utils/http.dart';

import '../utils/toJson.dart';

Future<DioResponse> fetchIssueType() async {
  var queryParams = {
    'txt': '',
    'doctype': 'Issue Type',
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

class IssueTypeDropdown extends StatefulWidget {
  final value;
  final Function onChanged;

  IssueTypeDropdown({this.value, this.onChanged});

  @override
  _IssueTypeDropdownState createState() => _IssueTypeDropdownState();
}

class _IssueTypeDropdownState extends State<IssueTypeDropdown> {
  String dropdownVal;
  Future<DioResponse> futureIssueType;

  @override
  void initState() {
    super.initState();
    futureIssueType = fetchIssueType();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DioResponse>(
        future: futureIssueType,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DropdownButton(
              value: widget.value,
              onChanged: (dynamic newVal) {
                widget.onChanged(newVal);
              },
              hint: Text('Issue Type'),
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
