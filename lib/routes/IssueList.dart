import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/http.dart';
import '../utils/helpers.dart';
import './issue.dart';

class Issue {
  final List keys;
  final List values;

  Issue({
    this.keys,
    this.values,
  });

  factory Issue.fromJson(json) {
    return Issue(
      keys: json['keys'],
      values: json['values'],
    );
  }
}

class IssueResponse {
  final values;
  final String error;

  IssueResponse(this.values, this.error);

  IssueResponse.fromJson(json)
      : values = Issue.fromJson(json["message"]),
        error = "";

  IssueResponse.withError(String errorValue)
      : values = List(),
        error = errorValue;
}

Future<IssueResponse> fetchIssue({Map filter, int page = 1}) async {
  int pageLength = 20;

  List<String> fields = [
    "`tabIssue`.`name`",
    "`tabIssue`.`status`",
    "`tabIssue`.`subject`",
    "`tabIssue`.`raised_by`",
    "`tabIssue`.`_comments`"
  ];
  List<List<String>> filters = [];

  String status = filter["status"];
  String priority = filter["priority"];
  String sla = filter["sla"];
  String user = filter["user"];
  String type = filter["type"];

  if (status != null) {
    filters.add(["Issue", "status", "=", "${status}"]);
  }

  if (priority != null) {
    filters.add(["Issue", "priority", "=", "${priority}"]);
  }

  if (sla != null) {
    filters.add(["Issue", "service_level_agreement", "=", "${sla}"]);
  }

  if (type != null) {
    filters.add(["Issue", "issue_type", "=", "${type}"]);
  }

  if (user != null) {
    filters.add(["Issue", "_assign", "like", "%${user}%"]);
  }

  var queryParams = {
    'doctype': 'Issue',
    'fields': jsonEncode(fields),
    'page_length': pageLength,
    'with_comment_count': true
  };

  queryParams['limit_start'] = (page * pageLength - pageLength).toString();

  if (filters.length != 0) {
    queryParams['filters'] = jsonEncode(filters);
  }

  final response2 = await dio.get('/method/frappe.desk.reportview.get',
      queryParameters: queryParams);
  if (response2.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return IssueResponse.fromJson(response2.data);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class IssueList extends StatefulWidget {
  final filter;
  const IssueList([this.filter]);

  @override
  _IssueListState createState() => _IssueListState();
}

class _IssueListState extends State<IssueList> {
  Future<IssueResponse> futureIssue;

  @override
  void initState() {
    super.initState();
    futureIssue = fetchIssue(filter: widget.filter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FilterIssue(),
              ));
        },
        child: Icon(
          Icons.filter_list,
          color: Colors.blueGrey,
          size: 50,
        ),
      ),
      appBar: AppBar(
        title: Text('Issue List'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              logout(context);
            },
          )
        ],
      ),
      body: FutureBuilder<IssueResponse>(
          future: futureIssue,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return IssueListBuilder(snapshot.data, widget.filter);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return CircularProgressIndicator();
          }),
    );
  }
}

class IssueListBuilder extends StatefulWidget {
  final issues;
  final filter;

  IssueListBuilder(this.issues, this.filter);

  @override
  _IssueListBuilderState createState() => _IssueListBuilderState();
}

class _IssueListBuilderState extends State<IssueListBuilder> {
  ScrollController _scrollController = ScrollController();

  int page = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        page = page + 1;
        fetchIssue(filter: widget.filter, page: page).then((onValue) {
          widget.issues.values.values.addAll(onValue.values.values);
          setState(() {});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: _scrollController,
        itemCount: widget.issues.values.values.length,
        itemBuilder: (context, index) {
          // if(index == widget.issues.values.length) {
          //   return CupertinoActivityIndicator();
          // }
          return Card(
            elevation: 8.0,
            margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: Container(
              decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                title: Container(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Text('${widget.issues.values.values[index][2]}',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                // leading: Container(
                //   padding: EdgeInsets.only(right: 12.0),
                //   decoration: new BoxDecoration(
                //       border: new Border(
                //           right: new BorderSide(width: 1.0, color: Colors.blue))),
                //   child: Icon(Icons.radio_button_checked, color: Colors.blue),
                // ),
                subtitle: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.radio_button_checked, color: Colors.white),
                      SizedBox(
                        width: 2,
                      ),
                      Text('${widget.issues.values.values[index][1]}',
                          style: TextStyle(color: Colors.white)),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.alternate_email, color: Colors.white),
                      SizedBox(
                        width: 2,
                      ),
                      Flexible(
                        child: Text('${widget.issues.values.values[index][3]}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.comment, color: Colors.white),
                      SizedBox(
                        width: 2,
                      ),
                      Text('${widget.issues.values.values[index][5]}',
                          style: TextStyle(color: Colors.white))
                    ],
                  ),
                ),
                trailing: Icon(Icons.keyboard_arrow_right,
                    color: Colors.white, size: 30.0),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            IssueDetail(widget.issues.values.values[index][0]),
                      ));
                },
              ),
            ),
          );
        });
  }
}
