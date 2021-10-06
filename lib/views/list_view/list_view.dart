import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/utils/navigation_helper.dart';
import 'package:frappe_app/views/base_view.dart';
import 'package:frappe_app/views/list_view/bottom_sheets/filters_bottom_sheet_view.dart';
import 'package:frappe_app/views/new_doc/new_doc_view.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../model/doctype_response.dart';

import '../../app/locator.dart';

import '../../views/list_view/list_view_viewmodel.dart';

import '../../config/palette.dart';
import '../../config/frappe_icons.dart';

import '../../utils/helpers.dart';
import '../../utils/frappe_icon.dart';
import '../../utils/enums.dart';

import '../../widgets/header_app_bar.dart';
import '../../widgets/frappe_button.dart';
import '../../widgets/list_item.dart';
import 'bottom_sheets/sort_by_fields_bottom_sheet_view.dart';

class CustomListView extends StatelessWidget {
  final DoctypeResponse meta;
  final String module;

  CustomListView({
    required this.meta,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return BaseView<ListViewViewModel>(
      onModelReady: (model) {
        model.meta = meta;
        model.init();
        model.getData();
        model.getDesktopPage(module);
        model.getSortableFields();
      },
      onModelClose: (model) {
        model.error = null;
        model.filters.clear();
      },
      builder: (context, model, child) => model.state == ViewState.busy
          ? Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : model.hasError
              ? handleError(
                  error: model.error,
                  context: context,
                  onRetry: () {
                    model.meta = meta;
                    model.getData();
                    model.getDesktopPage(meta.docs[0].module);
                  },
                )
              : RefreshIndicator(
                  onRefresh: () {
                    return Future.value(model.refresh());
                  },
                  child: Scaffold(
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerFloat,
                    floatingActionButton: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AddFilterButton(
                          appliedFilters: model.filters.length,
                          onPressed: () async {
                            var fields = model.getFilterableFields(
                              meta.docs[0].fields,
                            );

                            List<Filter> appliedFilters =
                                await showModalBottomSheet(
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
                        SizedBox(
                          width: 8,
                        ),
                        SortByButton(
                          sortOrder: model.sortOrder,
                          onPressed: () async {
                            var sort = await showModalBottomSheet(
                              context: context,
                              useRootNavigator: true,
                              isScrollControlled: true,
                              builder: (context) => SortByFieldsBottomSheetView(
                                fields: model.sortableFields,
                                selectedField: model.sortField,
                              ),
                            ) as Map?;

                            if (sort != null) {
                              model.updateSort(sort);
                            }
                          },
                          sortField: model.sortField.label!,
                        ),
                      ],
                    ),
                    appBar: buildAppBar(
                      title: model.meta.docs[0].name,
                      onPressed: () {
                        NavigationHelper.push(
                          context: context,
                          page: ShowSiblingDoctypes(
                            model: model,
                            title: model.meta.docs[0].name,
                          ),
                        );
                      },
                      actions: <Widget>[
                        _newDoc(context),
                      ],
                    ),
                    body: Container(
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
                ),
    );
  }

  Widget _newDoc(BuildContext context) {
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return NewDoc(meta: meta);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _generateList({
    required List<Filter> filters,
    required DoctypeResponse meta,
    required ListViewViewModel model,
  }) {
    return PagewiseListView(
      pageLoadController: model.pagewiseLoadController,
      padding: EdgeInsets.zero,
      showRetry: false,
      noItemsFoundBuilder: (context) {
        return _noItemsFoundBuilder(
          filters: filters,
          context: context,
          model: model,
        );
      },
      errorBuilder: (context, e) {
        return Container(
          height: MediaQuery.of(context).size.height - 200,
          child: handleError(
            error: e as ErrorResponse,
            context: context,
            onRetry: () {
              model.refresh();
            },
          ),
        );
      },
      itemBuilder: ((buildContext, entry, _) {
        late var e = entry as Map;
        return _generateItem(
          model: model,
          data: e,
          onListTap: () {
            model.onListTap(
              context: buildContext,
              name: e["name"],
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
    required Map data,
    required void Function() onListTap,
    required Function onButtonTap,
    required ListViewViewModel model,
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
      toggleLikeCallback: () {
        model.refresh();
      },
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
    required List<Filter> filters,
    required BuildContext context,
    required ListViewViewModel model,
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
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return NewDoc(meta: meta);
                  },
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
  final void Function()? onPressed;

  const AddFilterButton({
    required this.appliedFilters,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: FrappePalette.grey[700],
        padding: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.transparent,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
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
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
      onPressed: onPressed,
    );
  }
}

class SortByButton extends StatelessWidget {
  final String sortField;
  final String sortOrder;
  final void Function()? onPressed;

  const SortByButton({
    required this.sortField,
    required this.onPressed,
    required this.sortOrder,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: FrappePalette.grey[700],
        padding: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.transparent,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FrappeIcon(
            sortOrder == "desc"
                ? FrappeIcons.sort_descending
                : FrappeIcons.sort_ascending,
            color: Colors.white,
          ),
          SizedBox(
            width: 10,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 100,
            ),
            child: Text(
              "$sortField",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 10,
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
    required this.model,
    required this.title,
  });
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
                            item.label.toUpperCase(),
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
