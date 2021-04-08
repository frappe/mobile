import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/views/base_view.dart';
import 'package:frappe_app/views/list_view/bottom_sheets/filters_bottom_sheet_view.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../model/doctype_response.dart';

import '../../app/locator.dart';
import '../../app/router.gr.dart';

import '../../views/list_view/list_view_viewmodel.dart';

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

                return Scaffold(
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerFloat,
                  floatingActionButton: AddFilterButton(
                    appliedFilters: model.filters.length,
                    onPressed: () async {
                      var fields = model.getFilterableFields(
                        meta.docs[0].fields,
                      );

                      List<Filter> appliedFilters = await showModalBottomSheet(
                        useRootNavigator: true,
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => FiltersBottomSheetView(
                          fields: fields,
                          filters: model.filters,
                        ),
                      );

                      model.applyFilters(appliedFilters);
                    },
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (model.filters.isNotEmpty)
                            Container(
                              height: 50,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: model.filters.length,
                                itemBuilder: (context, index) {
                                  var filter = model.filters[index];
                                  var txt =
                                      "${filter.field.label} ${filter.filterOperator.label} ${filter.value}";
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 10,
                                    ),
                                    child: InputChip(
                                      label: Text(
                                        txt,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      deleteIcon: FrappeIcon(
                                        FrappeIcons.close_alt,
                                        size: 14,
                                      ),
                                      backgroundColor: FrappePalette.grey[200],
                                      shape: BeveledRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(6),
                                        ),
                                      ),
                                      onDeleted: () {
                                        model.removeFilter(index);
                                      },
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  );
                                },
                              ),
                            ),
                          Expanded(
                            child: _generateList(
                              model: model,
                              filters: model.filters,
                              meta: meta,
                            ),
                          ),
                        ],
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
    @required List<Filter> filters,
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
              context: buildContext,
              meta: meta,
              name: entry["name"],
            );
          },
          onButtonTap: (k, v) {
            // model.onButtonTap(key: k, value: v);
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
    @required List<Filter> filters,
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
}

class AddFilterButton extends StatelessWidget {
  final int appliedFilters;
  final Function onPressed;

  const AddFilterButton({
    Key key,
    @required this.appliedFilters,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: FrappePalette.grey[700],
      padding: EdgeInsets.all(8),
      shape: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FrappeIcon(
            FrappeIcons.filter,
            color: Colors.white,
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            'Add filter',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                4,
              ),
            ),
            child: Center(
              child: Text(
                appliedFilters.toString(),
              ),
            ),
          ),
        ],
      ),
      onPressed: onPressed,
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
          Navigator.of(context).pop();
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
                                    doctype: link.label,
                                    context: context,
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
