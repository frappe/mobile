import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/screens/filter_list.dart';
import 'package:frappe_app/utils/backend_service.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../main.dart';
import '../app.dart';
import '../config/palette.dart';
import '../utils/enums.dart';
import '../widgets/frappe_button.dart';
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
  static const int PAGE_SIZE = 10;
  final userId = Uri.decodeFull(localStorage.getString('userId'));
  var _pageLoadController;
  BackendService backendService;
  bool showLiked;

  @override
  void initState() {
    super.initState();
    backendService = BackendService(context, meta: widget.meta);
    _pageLoadController = PagewiseLoadController(
      pageSize: PAGE_SIZE,
      pageFuture: (pageIndex) {
        return backendService.fetchList(
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
    if (FilterList.getFieldFilterIndex(widget.filters, '_liked_by') != null) {
      showLiked = true;
    } else {
      showLiked = false;
    }
    return Scaffold(
      bottomNavigationBar: Container(
        height: 60,
        child: BottomAppBar(
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Spacer(),
              FrappeRaisedButton(
                minWidth: 120,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return FractionallySizedBox(
                        heightFactor: 0.96,
                        child: Router(
                          viewType: ViewType.filter,
                          doctype: widget.doctype,
                          filters: widget.filters,
                          filterCallback: (filters) {
                            widget.filters.clear();
                            widget.filters.addAll(filters);
                            setState(() {
                              _pageLoadController.reset();
                            });
                          },
                        ),
                      );
                    },
                  );
                },
                title: 'Filters (${widget.filters.length})',
                icon: FrappeIcons.filter,
              ),
              SizedBox(
                width: 10,
              ),
              FrappeRaisedButton(
                minWidth: 120,
                onPressed: () {
                  if (!showLiked) {
                    widget.filters.add([
                      widget.doctype,
                      '_liked_by',
                      'like',
                      '%$userId%',
                    ]);
                  } else {
                    int likedByIdx = FilterList.getFieldFilterIndex(
                      widget.filters,
                      '_liked_by',
                    );

                    if (likedByIdx != null) {
                      widget.filters.removeAt(likedByIdx);
                    }
                  }

                  setState(() {
                    showLiked = !showLiked;
                    _pageLoadController.reset();
                  });
                },
                title: 'Liked',
                icon: showLiked
                    ? FrappeIcons.favourite_active
                    : FrappeIcons.favourite_resting,
                iconSize: 16.0,
              ),
              Spacer()
            ],
          ),
        ),
      ),
      appBar: AppBar(
        elevation: 0.6,
        title: Text(widget.appBarTitle),
        actions: <Widget>[
          IconButton(
            icon: FrappeIcon(
              FrappeIcons.search,
              color: Palette.iconColor,
            ),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearch(widget),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Palette.primaryButtonColor,
              ),
              child: IconButton(
                icon: FrappeIcon(
                  FrappeIcons.small_add,
                  color: Colors.white,
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
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _pageLoadController.reset();
        },
        child: Container(
          color: Palette.bgColor,
          child: PagewiseListView(
            noItemsFoundBuilder: (context) {
              return Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('No Items Found'),
                    if (widget.filters.isNotEmpty)
                      FrappeFlatButton.small(
                        buttonType: ButtonType.secondary,
                        title: 'Clear Filters',
                        onPressed: () {
                          FilterList.clearFilters(widget.doctype);
                          widget.filters.clear();
                          _pageLoadController.reset();
                          setState(() {});
                        },
                      ),
                    FrappeFlatButton.small(
                      buttonType: ButtonType.primary,
                      title: 'Create New',
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
                    )
                  ],
                ),
              );
            },
            pageLoadController: _pageLoadController,
            itemBuilder: ((buildContext, entry, _) {
              var assignee = entry["_assign"] != null
                  ? json.decode(entry["_assign"])
                  : null;

              var likedBy = entry["_liked_by"] != null
                  ? json.decode(entry["_liked_by"])
                  : [];
              var isLikedByUser = likedBy.contains(userId);

              var seenBy =
                  entry["_seen"] != null ? json.decode(entry["_seen"]) : [];
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
                          name: entry["name"],
                        );
                      },
                    ),
                  );
                },
                isFav: isLikedByUser,
                seen: isSeenByUser,
                assignee: assignee != null && assignee.length > 0
                    ? ['_assign', assignee[0]]
                    : null,
                onButtonTap: (filter) {
                  widget.filters.clear();
                  widget.filters.addAll(
                    FilterList.generateFilters(widget.doctype, filter),
                  );
                  _pageLoadController.reset();
                  setState(() {});
                },
                title: entry[widget.meta["title_field"]] ?? entry["name"],
                modifiedOn: "${timeago.format(
                  DateTime.parse(
                    entry['modified'],
                  ),
                )}",
                name: entry["name"],
                status: ["status", entry["status"]],
                commentCount: entry["_comment_count"],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class CustomSearch extends SearchDelegate {
  final data;

  // TODO hintText
  CustomSearch(this.data);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: BackendService(context, meta: data.meta).fetchList(
          pageLength: 10,
          fieldnames: data.fieldnames,
          doctype: data.doctype,
          filters: [
            [data.doctype, data.meta["title_field"], 'like', '%$query%']
          ]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (_, index) {
              return ListTile(
                title: Text(
                  snapshot.data[index][data.meta["title_field"]],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Router(
                          viewType: ViewType.form,
                          doctype: data.doctype,
                          name: snapshot.data[index]["name"],
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
