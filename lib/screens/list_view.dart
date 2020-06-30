import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../main.dart';
import '../app.dart';
import '../config/palette.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';
import '../utils/http.dart';
import '../utils/response_models.dart';
import '../widgets/button.dart';
import '../widgets/list_item.dart';

class CustomListView extends StatefulWidget {
  final String doctype;
  final List fieldnames;
  final List filters;
  final Function filterCallback;
  final Function detailCallback;
  final String appBarTitle;
  final meta;

  CustomListView({
    @required this.doctype,
    @required this.meta,
    @required this.fieldnames,
    this.filters,
    this.filterCallback,
    @required this.appBarTitle,
    this.detailCallback,
  });

  @override
  _CustomListViewState createState() => _CustomListViewState();
}

class _CustomListViewState extends State<CustomListView> {
  Future<DioGetReportViewResponse> futureList;
  static const int PAGE_SIZE = 10;
  final userId = Uri.decodeFull(localStorage.getString('userId'));
  bool showLiked = false;
  var _pageLoadController;

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

  List<Widget> _buildFilters(List filters) {
    var chips = filters.asMap().entries.map((entry) {
      var value = entry.value;
      var key = entry.key;
      var label = widget.meta["field_label"][value[1]];
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: InputChip(
          deleteIconColor: Palette.darkGrey,
          backgroundColor: Colors.transparent,
          shape: OutlineInputBorder(
            borderSide: BorderSide(
              color: Palette.borderColor,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          label: Text(
            "$label ${value[2]} ${value[3]}",
            style: TextStyle(fontSize: 12),
          ),
          onDeleted: () {
            filters.removeAt(key);
            _pageLoadController.reset();
            setState(() {});
          },
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }).toList();

    return chips;
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: 70, left: 16),
      child: Row(
        children: <Widget>[
          widget.filters.length > 0
              ? Expanded(
                  child: FormBuilder(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Visibility(
                          visible: widget.filters.length > 0,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 8.0,
                              bottom: 12,
                              top: 12,
                            ),
                            child: Button(
                              buttonType: ButtonType.secondary,
                              title: 'Clear Filters',
                              onPressed: () {
                                setState(() {
                                  _pageLoadController.reset();
                                  widget.filters.clear();
                                  localStorage.setString(
                                      '${widget.doctype}Filter', null);
                                });
                              },
                            ),
                          ),
                        ),
                        ..._buildFilters(widget.filters)
                      ],
                    ),
                  ),
                )
              : Text('No Filters'),

          // Spacer(),
          // Text('20 of 99')
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageLoadController = PagewiseLoadController(
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
  }

  @override
  void dispose() {
    super.dispose();
    _pageLoadController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              snap: true,
              floating: true,
              expandedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(),
              ),
              title: Text(widget.appBarTitle),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: Palette.darkGrey,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Router(
                            viewType: ViewType.filter,
                            doctype: widget.doctype,
                            filters: widget.filters,
                          );
                        },
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    showLiked ? Icons.favorite : Icons.favorite_border,
                    // size: 18,
                    color: showLiked ? Colors.red : Palette.darkGrey,
                  ),
                  onPressed: () {
                    if (!showLiked) {
                      widget.filters.add(
                          [widget.doctype, '_liked_by', 'like', '%$userId%']);
                    } else {
                      int likedByIdx;
                      for (int i = 0; i < widget.filters.length; i++) {
                        if (widget.filters[i][1] == '_liked_by') {
                          likedByIdx = i;
                          break;
                        }
                      }
                      if (likedByIdx != null) {
                        widget.filters.removeAt(likedByIdx);
                      }
                    }

                    setState(() {
                      showLiked = !showLiked;
                      _pageLoadController.reset();
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: Palette.darkGrey,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Router(
                            viewType: ViewType.newForm,
                            doctype: widget.doctype,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () {
            _pageLoadController.reset();
            return Future.delayed(Duration(seconds: 1));
          },
          child: Container(
            color: Palette.bgColor,
            child: PagewiseListView(
              pageLoadController: _pageLoadController,
              itemBuilder: ((buildContext, entry, _) {
                int subjectFieldIndex =
                    entry[0].indexOf(widget.meta["subject_field"]);
                var key = entry[0];
                var value = entry[1];
                var assignee = value[4] != null ? json.decode(value[4]) : null;

                var likedBy = value[6] != null ? json.decode(value[6]) : [];
                var isLikedByUser = likedBy.contains(userId);

                var seenBy = value[5] != null ? json.decode(value[5]) : [];
                var isSeenByUser = seenBy.contains(userId);

                return ListItem(
                  doctype: widget.doctype,
                  onListTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Router(
                            viewType: ViewType.form,
                            doctype: widget.doctype,
                            name: value[0],
                          );
                        },
                      ),
                    );
                  },
                  isFav: isLikedByUser,
                  seen: isSeenByUser,
                  assignee: assignee != null && assignee.length > 0
                      ? [key[4], assignee[0]]
                      : null,
                  onButtonTap: (k, v) {
                    if (k == '_assign') {
                      widget.filters.add([widget.doctype, k, 'like', '%$v%']);
                    } else {
                      widget.filters.add([widget.doctype, k, '=', v]);
                    }
                    localStorage.setString(
                        '${widget.doctype}Filter', json.encode(widget.filters));
                    _pageLoadController.reset();
                    setState(() {});
                  },
                  title: value[subjectFieldIndex],
                  modifiedOn: "${timeago.format(
                    DateTime.parse(
                      value[3],
                    ),
                  )}",
                  name: value[0],
                  status: [key[1], value[1]],
                  commentCount: value[8],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
