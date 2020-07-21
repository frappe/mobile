import 'dart:convert';

import 'package:badges/badges.dart';
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
  static const int PAGE_SIZE = 10;
  final userId = Uri.decodeFull(localStorage.getString('userId'));
  var _pageLoadController;
  BackendService backendService;
  bool showLiked;

  @override
  void initState() {
    super.initState();
    backendService = BackendService(context);
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
              RaisedButton.icon(
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
                color: Colors.white,
                label: Text('Add Filters (${widget.filters.length})'),
                icon: FrappeIcon(
                  FrappeIcons.filter,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              RaisedButton.icon(
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
                label: Text('Show Liked'),
                color: Colors.white,
                icon: showLiked
                    ? FrappeIcon(
                        FrappeIcons.favourite_active,
                      )
                    : FrappeIcon(
                        FrappeIcons.favourite_resting,
                      ),
              ),
              Spacer()
            ],
          ),
        ),
      ),
      appBar: AppBar(
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
          // IconButton(
          //   icon: Badge(
          //     badgeColor: Colors.white,
          //     position: BadgePosition.bottomRight(),
          //     showBadge: widget.filters.isNotEmpty,
          //     badgeContent: Text("${widget.filters.length}"),
          //     child: FrappeIcon(
          //       FrappeIcons.filter,
          //       color: widget.filters.length > 0
          //           ? Colors.black
          //           : Palette.iconColor,
          //     ),
          //   ),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) {
          //           return Router(
          //             viewType: ViewType.filter,
          //             doctype: widget.doctype,
          //             filters: widget.filters,
          //           );
          //         },
          //       ),
          //     );
          //   },
          // ),
          // IconButton(
          //   icon: FrappeIcon(
          //     showLiked
          //         ? FrappeIcons.favourite_active
          //         : FrappeIcons.favourite_resting,
          //     color: showLiked ? null : Palette.iconColor,
          //   ),
          //   onPressed: () {
          //     if (!showLiked) {
          //       widget.filters.add([
          //         widget.doctype,
          //         '_liked_by',
          //         'like',
          //         '%$userId%',
          //       ]);
          //     } else {
          //       int likedByIdx = FilterList.getFieldFilterIndex(
          //         widget.filters,
          //         '_liked_by',
          //       );

          //       if (likedByIdx != null) {
          //         widget.filters.removeAt(likedByIdx);
          //       }
          //     }

          //     setState(() {
          //       showLiked = !showLiked;
          //       _pageLoadController.reset();
          //     });
          //   },
          // ),
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
                      Button(
                        buttonType: ButtonType.secondary,
                        title: 'Clear Filters',
                        onPressed: () {
                          FilterList.clearFilters(widget.doctype);
                          widget.filters.clear();
                          _pageLoadController.reset();
                          setState(() {});
                        },
                      ),
                    Button(
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
              int titleFieldIndex =
                  entry[0].indexOf(widget.meta["title_field"]);
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
                onButtonTap: (filter) {
                  widget.filters.clear();
                  widget.filters.addAll(
                    FilterList.generateFilters(widget.doctype, filter),
                  );
                  _pageLoadController.reset();
                  setState(() {});
                },
                title: value[titleFieldIndex],
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
      future: BackendService(context).fetchList(
          fieldnames: data.fieldnames,
          doctype: data.doctype,
          filters: [
            [data.doctype, 'subject', 'like', '%$query%']
          ]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (_, index) {
              return ListTile(
                title: Text(
                  snapshot.data[index][1][2],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Router(
                          viewType: ViewType.form,
                          doctype: data.doctype,
                          name: snapshot.data[index][1][0],
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
