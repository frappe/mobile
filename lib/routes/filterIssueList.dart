import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:support_app/utils/helpers.dart';
import 'package:support_app/widgets/issueTypeDropdown.dart';
import 'package:support_app/widgets/priorityDropdown.dart';
import 'package:support_app/widgets/userDropdown.dart';
import './IssueList.dart';
import '../widgets/issueStatusDropdown.dart';
import '../utils/http.dart';
import '../utils/toJson.dart';

Future<DioResponse> fetchSLA() async {
  var queryParams = {
    'txt': '',
    'doctype': 'Service Level Agreement',
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

class FilterIssueList extends StatefulWidget {
  @override
  _FilterIssueListState createState() => _FilterIssueListState();
}

class _FilterIssueListState extends State<FilterIssueList> {
  String issueDropdownVal;
  String priorityDropdownVal;
  String slaDropdownVal;
  String issueTypeDropdownVal;
  String userDropdownVal;

  // Future<DioResponse> futurePriority;
  Future<DioResponse> futureSLA;
  // Future<DioResponse> futureIssueType;
  // Future<DioResponse> futureUser;

  @override
  void initState() {
    super.initState();
    // futurePriority = fetchPriority();
    futureSLA = fetchSLA();
    // futureIssueType = fetchIssueType();
    // futureUser = fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              logout(context);
            },
          )
        ],
        title: Text('Filter Issue'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            var filters = {
              'status': issueDropdownVal,
              'priority': priorityDropdownVal,
              'sla': slaDropdownVal,
              'user': userDropdownVal,
              'type': issueTypeDropdownVal
            };
            return IssueList(filters);
          }));
        },
        child: Icon(
          Icons.done,
          color: Colors.blueGrey,
        ),
      ),
      body: GridView.count(
        padding: EdgeInsets.all(10),
        childAspectRatio: 2.0,
        crossAxisCount: 2,
        children: <Widget>[
          IssueStatusDropdown(
            value: issueDropdownVal,
            onChanged: (newVal) {
              setState(() {
                issueDropdownVal = newVal;
              });
            },
          ),
          PriorityDropdown(
            value: priorityDropdownVal,
            onChanged: (newVal) {
              setState(() {
                priorityDropdownVal = newVal;
              });
            },
          ),
          FutureBuilder<DioResponse>(
              future: futureSLA,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return DropdownButton(
                    value: slaDropdownVal,
                    onChanged: (dynamic newVal) {
                      setState(() {
                        slaDropdownVal = newVal;
                      });
                    },
                    hint: Text('SLA'),
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
              }),
          IssueTypeDropdown(
            value: issueTypeDropdownVal,
            onChanged: (newVal) {
              setState(() {
                issueTypeDropdownVal = newVal;
              });
            },
          ),
          UserDropdown(
            value: userDropdownVal,
            onChanged: (newVal) {
              setState(() {
                userDropdownVal = newVal;
              });
            },
          ),
        ],
      ),
    );
  }
}
