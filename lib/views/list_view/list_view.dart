import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/views/base_view.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../model/doctype_response.dart';

import '../../app/locator.dart';
import '../../app/router.gr.dart';

import '../../views/list_view/list_view_viewmodel.dart';
import '../../views/filter_list/filter_list_view.dart';

import '../../services/navigation_service.dart';

import '../../config/palette.dart';
import '../../config/frappe_icons.dart';

import '../../utils/helpers.dart';
import '../../utils/frappe_icon.dart';
import '../../utils/enums.dart';

import '../../widgets/header_app_bar.dart';
import '../../widgets/frappe_button.dart';
import '../../widgets/list_item.dart';

class CustomListView extends StatelessWidget {
  final DoctypeResponse meta;

  CustomListView({
    @required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    return BaseView<ListViewViewModel>(
      onModelReady: (model) {
        model.meta = meta;
        model.getData(meta.docs[0]);
        model.getDesktopPage(meta.docs[0].module);
      },
      onModelClose: (model) {
        model.filters = {};

        model.showLiked = false;
        model.error = null;
      },
      builder: (context, model, child) => model.state == ViewState.busy
          ? Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Builder(
              builder: (context) {
                if (model.error != null) {
                  return handleError(model.error);
                }

                var filters = model.filters;

                return Scaffold(
                  bottomNavigationBar: _bottomBar(
                    model: model,
                    filters: filters,
                    context: context,
                  ),
                  appBar: buildAppBar(
                    title: model.meta.docs[0].name,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowSiblingDoctypes(
                            model: model,
                            title: model.meta.docs[0].name,
                          ),
                        ),
                      );
                    },
                    actions: <Widget>[
                      _newDoc(),
                    ],
                  ),
                  body: RefreshIndicator(
                    onRefresh: () {
                      return Future.value(model.refresh());
                    },
                    child: Container(
                      color: Palette.bgColor,
                      child: _generateList(
                        model: model,
                        filters: filters,
                        meta: meta,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _newDoc() {
    return Padding(
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
              Routes.newDoc,
              arguments: NewDocArguments(meta: meta),
            );
          },
        ),
      ),
    );
  }

  Widget _generateList({
    @required Map filters,
    @required DoctypeResponse meta,
    @required ListViewViewModel model,
  }) {
    return PagewiseListView(
      pageLoadController: model.pagewiseLoadController,
      padding: EdgeInsets.zero,
      noItemsFoundBuilder: (context) {
        return _noItemsFoundBuilder(
          filters: filters,
          context: context,
          model: model,
        );
      },
      itemBuilder: ((buildContext, entry, _) {
        return _generateItem(
          model: model,
          data: entry,
          onListTap: () {
            model.onListTap(
              meta: meta,
              name: entry["name"],
            );
          },
          onButtonTap: (k, v) {
            model.onButtonTap(key: k, value: v);
          },
        );
      }),
    );
  }

  Widget _generateItem({
    @required Map data,
    @required Function onListTap,
    @required Function onButtonTap,
    @required ListViewViewModel model,
  }) {
    var assignee =
        data["_assign"] != null ? json.decode(data["_assign"]) : null;

    var likedBy =
        data["_liked_by"] != null ? json.decode(data["_liked_by"]) : [];
    var isLikedByUser = likedBy.contains(model.userId);

    var seenBy = data["_seen"] != null ? json.decode(data["_seen"]) : [];
    var isSeenByUser = seenBy.contains(model.userId);

    return ListItem(
      doctype: model.meta.docs[0].name,
      likeCount: likedBy.length,
      onListTap: onListTap,
      isFav: isLikedByUser,
      seen: isSeenByUser,
      assignee: assignee != null && assignee.length > 0 ? assignee : null,
      onButtonTap: onButtonTap,
      title: getTitle(model.meta.docs[0], data),
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

  Widget _noItemsFoundBuilder({
    @required Map filters,
    @required BuildContext context,
    @required ListViewViewModel model,
  }) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('No Items Found'),
          if (filters.isNotEmpty)
            FrappeFlatButton.small(
              buttonType: ButtonType.secondary,
              title: 'Clear Filters',
              onPressed: () {
                model.clearFilters();
              },
            ),
          FrappeFlatButton.small(
            buttonType: ButtonType.primary,
            title: 'Create New',
            onPressed: () {
              locator<NavigationService>().navigateTo(
                Routes.newDoc,
                arguments: NewDocArguments(
                  meta: meta,
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _bottomBar({
    @required Map filters,
    @required BuildContext context,
    @required ListViewViewModel model,
  }) {
    return Container(
      height: 60,
      child: BottomAppBar(
        color: Colors.white,
        child: Row(
          children: <Widget>[
            Spacer(),
            FrappeRaisedButton(
              minWidth: 120,
              onPressed: () async {
                Map newFilters = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return FilterList(
                        filters: filters,
                        doctype: model.meta.docs[0].name,
                        meta: meta,
                      );
                    },
                  ),
                );

                model.applyFilters(newFilters);
              },
              title: 'Filters (${model.filters.length})',
              icon: FrappeIcons.filter,
            ),
            SizedBox(
              width: 10,
            ),
            FrappeRaisedButton(
              minWidth: 120,
              onPressed: () {
                model.toggleLiked(
                  model.meta.docs[0].name,
                );
              },
              title: 'Liked',
              icon: model.showLiked
                  ? FrappeIcons.favourite_active
                  : FrappeIcons.favourite_resting,
              iconSize: 16.0,
            ),
            Spacer()
          ],
        ),
      ),
    );
  }
}

class ShowSiblingDoctypes extends StatelessWidget {
  final ListViewViewModel model;
  final String title;

  const ShowSiblingDoctypes({
    Key key,
    this.model,
    this.title,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(
        title: title,
        expanded: true,
        onPressed: () {
          locator<NavigationService>().pop();
        },
      ),
      body: model.state == ViewState.busy
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Builder(
              builder: (context) {
                List<Widget> listItems = [];

                model.desktopPageResponse.message.cards.items.forEach(
                  (item) {
                    listItems.add(Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          title: Text(
                            item.label,
                            style: TextStyle(
                              color: FrappePalette.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                          visualDensity: VisualDensity(
                            vertical: -4,
                          ),
                        ),
                        ...item.links.where((link) {
                          return link.type != "DocType";
                        }).map(
                          (link) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: ListTile(
                                visualDensity: VisualDensity(
                                  vertical: -4,
                                ),
                                tileColor: title == link.label
                                    ? Palette.bgColor
                                    : Colors.white,
                                title: Text(link.label),
                                onTap: () {
                                  model.switchDoctype(
                                    link.label,
                                  );
                                },
                              ),
                            );
                          },
                        ).toList()
                      ],
                    ));
                  },
                );

                return ListView(
                  children: listItems,
                );
              },
            ),
    );
  }
}
