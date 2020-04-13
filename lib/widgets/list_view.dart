import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:support_app/utils/helpers.dart';
import 'package:support_app/utils/http.dart';
import 'package:support_app/utils/response_models.dart';

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

  if (filters!=null && filters.length != 0) {
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
  final String app_bar_title;
  final wireframe;

  CustomListView(
      {@required this.doctype,
      this.wireframe,
      @required this.fieldnames,
      this.filters,
      this.filterCallback,
      @required this.app_bar_title,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
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
          color: Colors.blueGrey,
          size: 50,
        ),
      ),
      appBar: AppBar(
        title: Text(widget.app_bar_title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              logout(context);
            },
          )
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
            return CircularProgressIndicator();
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

  ListBuilder({this.list, this.filters, this.fieldnames, this.doctype, this.detailCallback, this.wireframe});

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
    int subject_field_index = widget.list.values.keys.indexOf(widget.wireframe["subject_field"]);
    
    return ListView.builder(
        controller: _scrollController,
        itemCount: widget.list.values.values.length,
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
                  child: Text('${widget.list.values.values[index][subject_field_index]}',
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
                      Text('${widget.list.values.values[index][1]}',
                          style: TextStyle(color: Colors.white)),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Text('${widget.list.values.values[index][3]}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('${widget.list.values.values[index][5]}',
                          style: TextStyle(color: Colors.white))
                    ],
                  ),
                ),
                trailing: Icon(Icons.keyboard_arrow_right,
                    color: Colors.white, size: 30.0),
                onTap: () {
                  widget.detailCallback(widget.list.values.values[index][0]);
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) =>
                  //           IssueDetail(widget.list.values.values[index][0]),
                  //     ));
                },
              ),
            ),
          );
        });
  }
}
