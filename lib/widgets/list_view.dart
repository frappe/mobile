import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/main.dart';
import 'package:frappe_app/widgets/list_item.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../utils/helpers.dart';
import '../utils/http.dart';
import '../utils/response_models.dart';

import '../constants.dart';

class CustomListView extends StatefulWidget {
  final String doctype;
  final List fieldnames;
  final List filters;
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

class _CustomListViewState extends State<CustomListView> with ChangeNotifier {
  Future<DioGetReportViewResponse> futureList;
  static const int PAGE_SIZE = 10;
  final user = localStorage.getString('user');
  bool showLiked = false;

  Future<List> _fetchList(
      {@required List fieldnames,
      @required String doctype,
      List filters,
      pageLength,
      offset}) async {
    var queryParams = {
      'doctype': doctype,
      'fields': jsonEncode(fieldnames),
      'page_length': pageLength,
      'with_comment_count': true
    };

    queryParams['limit_start'] = offset.toString();

    if (filters != null && filters.length != 0) {
      queryParams['filters'] = jsonEncode(filters);
    }

    final response2 = await dio.get(
      '/method/frappe.desk.reportview.get',
      queryParameters: queryParams,
      options: Options(
        validateStatus: (status) {
          return status < 500;
        },
      ),
    );
    if (response2.statusCode == 200) {
      return DioGetReportViewResponse.fromJson(response2.data).values;
    } else if (response2.statusCode == 403) {
      logout(context);
    } else {
      throw Exception('Failed to load album');
    }
  }

  void choiceAction(String choice) {
    if (choice == Constants.Logout) {
      logout(context);
    } else if (choice == 'showLiked') {
      if(!showLiked) {
        widget.filters.add([widget.doctype, '_liked_by', 'like', '%$user%']);
      } else {
        int likedByIdx;
        for(int i = 0; i < widget.filters.length; i++) {
          if (widget.filters[i][1] == '_liked_by') {
            likedByIdx = i;
            break;
          }
        }
        widget.filters.removeAt(likedByIdx);
      }
      showLiked = !showLiked;

      setState(() {});
    }
  }

  Widget _buildHeader() {
    return Container(
      // height: 80,
      decoration: BoxDecoration(color: Palette.offWhite),
      padding: EdgeInsets.only(top: 70, left: 16),
      child: Row(
        children: <Widget>[
          widget.filters.length > 0
              ? Text('Filters Applied')
              : Text('No Filters'),
          // Text(widget.filters.toString()),
          widget.filters.length > 0
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      widget.filters.clear();
                      localStorage.setString('IssueFilter', null);
                    });
                  },
                )
              : Container(),
          // Spacer(),
          // Text('20 of 99')
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _pageLoadController = PagewiseLoadController(
      pageSize: PAGE_SIZE,
      pageFuture: (pageIndex) {
        return _fetchList(
          doctype: widget.doctype,
          fieldnames: widget.fieldnames,
          pageLength: PAGE_SIZE,
          filters: widget.filters,
          offset: pageIndex * PAGE_SIZE,
        );
      },
    );

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              leading: PopupMenuButton<String>(
                onSelected: choiceAction,
                icon: CircleAvatar(
                  child: Text(
                    user[0].toUpperCase(),
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Palette.bgColor,
                ),
                itemBuilder: (BuildContext context) {
                  return Constants.choices.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
              pinned: true,
              snap: true,
              floating: true,
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(),
              ),
              title: Text(widget.appBarTitle),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: () {
                    widget.filterCallback(widget.filters);
                  },
                ),
                PopupMenuButton<String>(
                    onSelected: choiceAction,
                    itemBuilder: (BuildContext context) => [
                          CheckedPopupMenuItem(
                            checked: showLiked,
                            value: 'showLiked',
                            child: Text("Show liked"),
                          )
                        ]),
              ],
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () {
            var val = _fetchList(
              doctype: widget.doctype,
              fieldnames: widget.fieldnames,
              pageLength: PAGE_SIZE,
              filters: widget.filters,
            );
            setState(() {});
            return val;
          },
          child: Container(
            color: Palette.bgColor,
            child: PagewiseListView(
              pageLoadController: _pageLoadController,
              itemBuilder: ((buildContext, entry, _) {
                int subjectFieldIndex =
                    entry[0].indexOf(widget.wireframe["subject_field"]);
                var key = entry[0];
                var value = entry[1];
                var assignee = value[6] != null ? json.decode(value[6]) : null;

                var likedBy = value[10] != null ? json.decode(value[10]) : [];
                var isLikedByUser = likedBy.contains(user);

                var seenBy = value[7] != null ? json.decode(value[7]) : [];
                var isSeenByUser = seenBy.contains(user);

                return ListItem(
                  doctype: widget.doctype,
                  onListTap: () {
                    widget.detailCallback(
                      value[0],
                      value[subjectFieldIndex],
                    );
                  },
                  isFav: isLikedByUser,
                  seen: isSeenByUser,
                  assignee: assignee != null && assignee.length > 0
                      ? [key[6], assignee[0]]
                      : null,
                  onButtonTap: (k, v) {
                    if (k == '_assign') {
                      widget.filters.add([widget.doctype, k, 'like', '%$v%']);
                    } else {
                      widget.filters.add([widget.doctype, k, '=', v]);
                    }
                    localStorage.setString(
                        'IssueFilter', json.encode(widget.filters));
                    setState(() {});
                  },
                  title: value[subjectFieldIndex],
                  modifiedOn: "${timeago.format(DateTime.parse(
                    value[5],
                  ))}",
                  name: value[0],
                  status: [key[1], value[1]],
                  commentCount: value[11],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
