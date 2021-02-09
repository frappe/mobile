import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
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
  final String doctype;

  CustomListView({
    @required this.doctype,
  });

  @override
  Widget build(BuildContext context) {
    return BaseView<ListViewViewModel>(
      onModelReady: (model) {
        model.getData(doctype);
      },
      onModelClose: (model) {
        model.filters = {};
        model.meta = null;
        model.showLiked = false;
        model.error = null;
        model.pagewiseLoadController.dispose();
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
                var meta = model.meta;
                var filters = model.filters;

                return Scaffold(
                  bottomNavigationBar: _bottomBar(
                    model: model,
                    filters: filters,
                    context: context,
                  ),
                  body: HeaderAppBar(
                    subtitle: doctype,
                    subActions: <Widget>[
                      _newDoc(model),
                    ],
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
                  ),
                );
              },
            ),
    );
  }

  Widget _newDoc(ListViewViewModel model) {
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
              arguments: NewDocArguments(doctype: doctype, meta: model.meta),
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
          meta: meta.docs[0],
          onListTap: () {
            model.onListTap(
              doctype: doctype,
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
    @required DoctypeDoc meta,
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
      doctype: doctype,
      onListTap: onListTap,
      isFav: isLikedByUser,
      seen: isSeenByUser,
      assignee: assignee != null && assignee.length > 0
          ? ['_assign', assignee[0]]
          : null,
      onButtonTap: onButtonTap,
      title: getTitle(meta, data),
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
                  doctype: doctype,
                  meta: model.meta,
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
                        doctype: doctype,
                        meta: model.meta,
                      );
                    },
                  ),
                );

                // Map newFilters = await showModalBottomSheet(
                //   context: context,
                //   isScrollControlled: true,
                //   builder: (BuildContext context) {
                //     return FractionallySizedBox(
                //       heightFactor: 0.96,
                //       child: FilterList(
                //         filters: filters,
                //         doctype: doctype,
                //         meta: model.meta,
                //       ),
                //     );
                //   },
                // );

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
                  doctype,
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
