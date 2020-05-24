import 'dart:convert';

import 'package:flutter/material.dart';

import '../utils/helpers.dart';
import '../utils/http.dart';
import '../utils/response_models.dart';

import '../constants.dart';

Future<DioGetReportViewResponse> fetchList(
    {@required List fieldnames,
    @required String doctype,
    List filters,
    int page = 1}) async {
  int pageLength = 20;

  var queryParams = {
    'doctype': doctype,
    'fields': jsonEncode(fieldnames),
    'page_length': pageLength,
    'with_comment_count': true
  };

  queryParams['limit_start'] = (page * pageLength - pageLength).toString();

  if (filters != null && filters.length != 0) {
    queryParams['filters'] = jsonEncode(filters);
  }

  final response2 = await dio.get('/method/frappe.desk.reportview.get',
      queryParameters: queryParams);
  if (response2.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return DioGetReportViewResponse.fromJson(response2.data);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class CustomListView extends StatefulWidget {
  final String doctype;
  final List fieldnames;
  final List<List<String>> filters;
  final Function filterCallback;
  final Function detailCallback;
  final String appBarTitle;
  final wireframe;

  CustomListView(
      {@required this.doctype,
      this.wireframe,
      @required this.fieldnames,
      this.filters,
      this.filterCallback,
      @required this.appBarTitle,
      this.detailCallback});

  @override
  _CustomListViewState createState() => _CustomListViewState();
}

class _CustomListViewState extends State<CustomListView> {
  Future<DioGetReportViewResponse> futureList;

  @override
  void initState() {
    super.initState();
    futureList = fetchList(
        filters: widget.filters,
        doctype: widget.doctype,
        fieldnames: widget.fieldnames);
  }

  void choiceAction(String choice) {
    if (choice == Constants.Logout) {
      logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      floatingActionButton: FloatingActionButton(
        // backgroundColor: Colors.white,
        onPressed: () {
          widget.filterCallback();
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => FilterIssue(),
          //     ));
        },
        child: Icon(
          Icons.filter_list,
          // color: Colors.blueGrey,
          size: 50,
        ),
      ),
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return Constants.choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.exit_to_app),
          //   onPressed: () async {
          //     logout(context);
          //   },
          // )
        ],
      ),
      body: FutureBuilder<DioGetReportViewResponse>(
          future: futureList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListBuilder(
                list: snapshot.data,
                filters: widget.filters,
                fieldnames: widget.fieldnames,
                doctype: widget.doctype,
                detailCallback: widget.detailCallback,
                wireframe: widget.wireframe,
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}

class ListBuilder extends StatefulWidget {
  final list;
  final List<List<String>> filters;
  final List fieldnames;
  final String doctype;
  final Function detailCallback;
  final wireframe;

  ListBuilder(
      {this.list,
      this.filters,
      this.fieldnames,
      this.doctype,
      this.detailCallback,
      this.wireframe});

  @override
  _ListBuilderState createState() => _ListBuilderState();
}

class _ListBuilderState extends State<ListBuilder> {
  ScrollController _scrollController = ScrollController();

  int page = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        page = page + 1;
        fetchList(
                filters: widget.filters,
                page: page,
                fieldnames: widget.fieldnames,
                doctype: widget.doctype)
            .then((onValue) {
          widget.list.values.values.addAll(onValue.values.values);
          setState(() {});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int subjectFieldIndex =
        widget.list.values.keys.indexOf(widget.wireframe["subject_field"]);

    return ListView.builder(
        controller: _scrollController,
        itemCount: widget.list.values.values.length,
        itemBuilder: (context, index) {
          // if(index == widget.issues.values.length) {
          //   return CupertinoActivityIndicator();
          // }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Divider(
                height: 10.0,
              ),
              ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 8, left: 10),
                  child: Icon(
                    Icons.lens,
                    size: 20,
                    color: setStatusColor(widget.list.values.values[index][1]),
                  ),
                ),
                title: Text(
                    '${widget.list.values.values[index][subjectFieldIndex]}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.grey[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                subtitle: Container(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: Text('${widget.list.values.values[index][3]}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                                fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.question_answer,
                        color: Colors.grey[600], size: 20.0),
                    Text('${widget.list.values.values[index][5]}',
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                onTap: () {
                  widget.detailCallback(widget.list.values.values[index][0],
                      widget.list.values.values[index][subjectFieldIndex]);
                },
              ),
            ],
          );
        });
  }
}
