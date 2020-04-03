import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:support_app/utils/http.dart';

import '../utils/toJson.dart';

Future<DioResponse> fetchUser() async {
  var queryParams = {
    'txt': '',
    'doctype': 'User',
    'reference_doctype': '',
    'query': 'frappe.core.doctype.user.user.user_query',
    'filters': {"user_type": "System User"}
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

class UserDropdown extends StatefulWidget {
  final value;
  final Function onChanged;

  UserDropdown({this.value, this.onChanged});

  @override
  _UserDropdownState createState() => _UserDropdownState();
}

class _UserDropdownState extends State<UserDropdown> {
  String dropdownVal;
  Future<DioResponse> futureUser;

  @override
  void initState() {
    super.initState();
    futureUser = fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DioResponse>(
        future: futureUser,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DropdownButton(
              isExpanded: true,
              value: widget.value,
              onChanged: (dynamic newVal) {
                widget.onChanged(newVal);
              },
              hint: Text('User'),
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
