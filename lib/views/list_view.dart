import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../datamodels/doctype_response.dart';

import '../app.dart';
import '../app/locator.dart';
import '../app/router.gr.dart';

import '../views/filter_list.dart';

import '../services/api/api.dart';
import '../services/navigation_service.dart';

import '../config/palette.dart';
import '../config/frappe_icons.dart';

import '../utils/cache_helper.dart';
import '../utils/helpers.dart';
import '../utils/config_helper.dart';
import '../utils/frappe_icon.dart';
import '../utils/enums.dart';

import '../widgets/frappe_button.dart';
import '../widgets/list_item.dart';
import 'no_internet.dart';

class CustomListView extends StatefulWidget {
  final String doctype;
  final List fieldnames;
  final List filters;
  final Function filterCallback;
  final Function detailCallback;
  final String appBarTitle;
  final DoctypeDoc meta;

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
  final userId = ConfigHelper().userId;
  var _pageLoadController;
  bool showLiked;

  @override
  void dispose() {
    super.dispose();
    _pageLoadController?.dispose();
  }

  Widget _generateItem(Map data) {
    var assignee =
        data["_assign"] != null ? json.decode(data["_assign"]) : null;

    var likedBy =
        data["_liked_by"] != null ? json.decode(data["_liked_by"]) : [];
    var isLikedByUser = likedBy.contains(userId);

    var seenBy = data["_seen"] != null ? json.decode(data["_seen"]) : [];
    var isSeenByUser = seenBy.contains(userId);

    return ListItem(
      doctype: widget.doctype,
      onListTap: () {
        locator<NavigationService>().navigateTo(
          Routes.customRouter,
          arguments: CustomRouterArguments(
            viewType: ViewType.form,
            doctype: widget.doctype,
            name: data["name"],
          ),
        );
      },
      isFav: isLikedByUser,
      seen: isSeenByUser,
      assignee: assignee != null && assignee.length > 0
          ? ['_assign', assignee[0]]
          : null,
      onButtonTap: (filter) async {
        widget.filters.clear();
        widget.filters.addAll(
          await FilterList.generateFilters(widget.doctype, filter),
        );
        _pageLoadController.reset();
        setState(() {});
      },
      title: getTitle(widget.meta, data),
      modifiedOn: "${timeago.format(
        DateTime.parse(
          data['modified'],
        ),
      )}",
      name: data["name"],
      status: ["status", data["status"]],
      commentCount: data["_comment_count"],
    );
  }

  Widget _noItemsFoundBuilder() {
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
              locator<NavigationService>().navigateTo(
                Routes.customRouter,
                arguments: CustomRouterArguments(
                  viewType: ViewType.newForm,
                  doctype: widget.doctype,
                ),
              );
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(
      context,
    );

    // if (connectionStatus == ConnectivityStatus.offline ||
    //     connectionStatus == null) {
    _pageLoadController = PagewiseLoadController(
      pageSize: PAGE_SIZE,
      pageFuture: (pageIndex) {
        return locator<Api>().fetchList(
          meta: widget.meta,
          doctype: widget.doctype,
          fieldnames: widget.fieldnames,
          pageLength: PAGE_SIZE,
          filters: widget.filters,
          offset: pageIndex * PAGE_SIZE,
        );
      },
    );
    // }

    // _pageLoadController = PagewiseLoadController(
    //   pageSize: PAGE_SIZE,
    //   pageFuture: (pageIndex) {
    //     return BackendService.fetchList(
    //       doctype: widget.doctype,
    //       fieldnames: widget.fieldnames,
    //       pageLength: PAGE_SIZE,
    //       filters: widget.filters,
    //       offset: pageIndex * PAGE_SIZE,
    //       meta: widget.meta,
    //     );
    //   },
    // );

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
                        child: CustomRouter(
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
                  locator<NavigationService>().navigateTo(
                    Routes.customRouter,
                    arguments: CustomRouterArguments(
                      viewType: ViewType.newForm,
                      doctype: widget.doctype,
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
        child: FutureBuilder(
          future: verifyOnline(),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              bool isOnline = snapshot.data;
              return Container(
                color: Palette.bgColor,
                child: isOnline
                    ? PagewiseListView(
                        noItemsFoundBuilder: (context) {
                          return _noItemsFoundBuilder();
                        },
                        pageLoadController: _pageLoadController,
                        itemBuilder: ((buildContext, entry, _) {
                          return _generateItem(entry);
                        }),
                      )
                    : FutureBuilder(
                        future: CacheHelper.getCache('${widget.doctype}List'),
                        builder: (buildContext, snapshot) {
                          if (snapshot.hasData &&
                              snapshot.connectionState ==
                                  ConnectionState.done) {
                            var list = snapshot.data["data"];

                            if (list != null) {
                              list = list;
                              return ListView.builder(
                                itemCount: list.length,
                                itemBuilder: (context, index) {
                                  return _generateItem(list[index]);
                                },
                              );
                            } else {
                              return NoInternet(true);
                            }
                          } else if (snapshot.hasError) {
                            return Text(snapshot.error);
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
              );
            } else if (snapshot.hasError) {
              return handleError(snapshot.error);
            } else {
              return CircularProgressIndicator();
            }
          },
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
    var titleField;
    if (hasTitle(data.meta)) {
      titleField = data.meta["title_field"];
    } else {
      titleField = "name";
    }
    return FutureBuilder(
      future: locator<Api>().fetchList(
          pageLength: 10,
          fieldnames: data.fieldnames,
          doctype: data.doctype,
          meta: data.meta,
          filters: [
            [data.doctype, titleField, 'like', '%$query%']
          ]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (_, index) {
              return ListTile(
                title: Text(
                  snapshot.data[index][titleField],
                ),
                onTap: () {
                  locator<NavigationService>().navigateTo(
                    Routes.customRouter,
                    arguments: CustomRouterArguments(
                      viewType: ViewType.form,
                      doctype: data.doctype,
                      name: snapshot.data[index]["name"],
                    ),
                  );
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return handleError(snapshot.error);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
