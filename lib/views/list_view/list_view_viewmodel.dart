import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/model/desk_sidebar_items_response.dart';
import 'package:frappe_app/model/desktop_page_response.dart';
import 'package:frappe_app/views/form_view/form_view.dart';
import 'package:injectable/injectable.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import '../../app/locator.dart';

import '../../model/doctype_response.dart';
import '../../model/offline_storage.dart';

import '../../services/api/api.dart';

import '../../model/config.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';
import '../../utils/helpers.dart';

import '../../views/base_viewmodel.dart';

@lazySingleton
class ListViewViewModel extends BaseViewModel {
  PagewiseLoadController? pagewiseLoadController;
  late DoctypeResponse meta;
  ErrorResponse? error;
  List<Filter> filters = [];
  bool showLiked = false;
  var userId = Config().userId;
  late DesktopPageResponse desktopPageResponse;

  refresh() {
    pagewiseLoadController?.reset();
  }

  bool get hasError => error != null;

  getData(DoctypeDoc meta) async {
    setState(ViewState.busy);
    try {
      var isOnline = await verifyOnline();

      if (isOnline) {
        pagewiseLoadController = PagewiseLoadController(
          pageSize: Constants.pageSize,
          pageFuture: (pageIndex) {
            var transformedFilters = filters.map((filter) {
              String value;
              if (filter.field.fieldtype == "Check") {
                value = filter.value == "Yes" ? "1" : "0";
              } else if (filter.filterOperator.value == "like") {
                value = "%${filter.value}%";
              } else {
                value = filter.value!;
              }

              return [
                meta.name,
                filter.field.fieldname,
                filter.filterOperator.value,
                value,
              ];
            }).toList();

            return locator<Api>().fetchList(
              filters: transformedFilters,
              meta: meta,
              doctype: meta.name,
              orderBy: '`tab${meta.name}`.`modified` desc',
              fieldnames: generateFieldnames(
                meta.name,
                meta,
              ),
              pageLength: Constants.pageSize,
              offset: pageIndex! * Constants.pageSize,
            );
          },
        );
      } else {
        pagewiseLoadController = PagewiseLoadController(
          pageSize: Constants.offlinePageSize,
          pageFuture: (pageIndex) {
            return Future.delayed(
              Duration(seconds: 0),
              () {
                var response = OfflineStorage.getItem(
                  '${meta.name}List',
                );
                return response["data"];
              },
            );
          },
        );
      }
      error = null;
    } catch (e) {
      error = e as ErrorResponse;
    }

    setState(ViewState.idle);
  }

  onListTap({
    required String name,
    required BuildContext context,
  }) {
    {
      pushNewScreen(
        context,
        screen: FormView(
          name: name,
          meta: meta,
        ),
        withNavBar: true,
      );
    }
  }

  // onButtonTap({
  //   @required String key,
  //   @required String value,
  // }) {
  //   filters[key] = value;
  //   pagewiseLoadController.reset();
  //   notifyListeners();
  // }

  getDesktopPage(String module) async {
    setState(ViewState.busy);
    try {
      var isOnline = await verifyOnline();

      if (isOnline) {
        var deskItems = await locator<Api>().getDeskSideBarItems();

        var desktopPage = module;
        for (final element in deskItems.message) {
          if (element.module == module) {
            desktopPage = element.name;
            break;
          }
        }

        desktopPageResponse = await locator<Api>().getDesktopPage(desktopPage);
      } else {
        var deskSidebarItemsCache = OfflineStorage.getItem(
          'deskSidebarItems',
        )["data"];

        late DeskSidebarItemsResponse deskItems;

        if (deskSidebarItemsCache != null) {
          deskItems = DeskSidebarItemsResponse.fromJson(
            deskSidebarItemsCache,
          );
        } else {
          throw ErrorResponse(
            statusCode: HttpStatus.serviceUnavailable,
          );
        }

        var desktopPage = module;

        for (final element in deskItems.message) {
          if (element.module == module) {
            desktopPage = element.name;
            break;
          }
        }

        var offlinedesktopPageResponse =
            OfflineStorage.getItem('${desktopPage}Doctypes')["data"];

        if (offlinedesktopPageResponse != null) {
          desktopPageResponse =
              DesktopPageResponse.fromJson(offlinedesktopPageResponse);
        } else {
          throw ErrorResponse(
            statusCode: HttpStatus.serviceUnavailable,
          );
        }
      }
    } catch (e) {
      error = e as ErrorResponse;
    }
    setState(ViewState.idle);
  }

  switchDoctype({
    required String doctype,
    required BuildContext context,
  }) async {
    var _meta = await OfflineStorage.getMeta(doctype);

    if (_meta.docs[0].issingle == 1) {
      pushNewScreen(
        context,
        screen: FormView(
          meta: _meta,
          name: _meta.docs[0].name,
        ),
        withNavBar: true,
      );
    } else {
      Navigator.of(context).pop();
      meta = _meta;
      getData(_meta.docs[0]);
    }
  }

  removeFilter(int index) {
    filters.removeAt(index);
    getData(meta.docs[0]);
  }

  clearFilters() {
    filters.clear();
    pagewiseLoadController?.reset();
    notifyListeners();
  }

  applyFilters(List<Filter>? appliedFilters) {
    if (appliedFilters != null) {
      if (appliedFilters.isNotEmpty) {
        List<Filter> appliedFiltersClone = [];
        appliedFilters.forEach(
          (appliedFilter) {
            appliedFiltersClone.add(
              Filter.fromJson(
                json.decode(
                  json.encode(
                    appliedFilter,
                  ),
                ),
              ),
            );
          },
        );

        filters = appliedFiltersClone;
        getData(meta.docs[0]);
      } else {
        filters = [];
        getData(meta.docs[0]);
      }
    }
  }

  List<DoctypeField> getFilterableFields(List<DoctypeField> fields) {
    return fields.where((field) {
      return field.fieldtype != "Section Break" &&
          field.fieldtype != "Column Break" &&
          field.hidden != 1;
    }).toList();
  }
}
