import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/model/desktop_page_response.dart';
import 'package:frappe_app/views/form_view/form_view.dart';
import 'package:injectable/injectable.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import '../../app/locator.dart';
import '../../app/router.gr.dart';

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
  PagewiseLoadController pagewiseLoadController;
  DoctypeResponse meta;
  Response error;
  List<Filter> filters = [];
  bool showLiked = false;
  var userId = Config().userId;
  DesktopPageResponse desktopPageResponse;

  refresh() {
    pagewiseLoadController.reset();
  }

  getData(DoctypeDoc meta) async {
    setState(ViewState.busy);
    try {
      var isOnline = await verifyOnline();

      if (isOnline) {
        pagewiseLoadController = PagewiseLoadController(
          pageSize: Constants.pageSize,
          pageFuture: (pageIndex) {
            var transformedFilters = filters.map((filter) {
              return [
                meta.name,
                filter.field.fieldname,
                filter.filterOperator.value,
                filter.value
              ];
            }).toList();

            return locator<Api>().fetchList(
              filters: transformedFilters,
              meta: meta,
              doctype: meta.name,
              fieldnames: generateFieldnames(
                meta.name,
                meta,
              ),
              pageLength: Constants.pageSize,
              offset: pageIndex * Constants.pageSize,
            );
          },
        );
      } else {
        pagewiseLoadController = PagewiseLoadController(
          pageSize: Constants.offlinePageSize,
          pageFuture: (pageIndex) {
            return Future.delayed(
              Duration(seconds: 1),
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
    } catch (e) {
      error = e;
    }

    setState(ViewState.idle);
  }

  onListTap({
    @required DoctypeResponse meta,
    @required String name,
    @required BuildContext context,
  }) {
    {
      pushNewScreenWithRouteSettings(
        context,
        settings: RouteSettings(name: Routes.formView),
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
    desktopPageResponse = await locator<Api>().getDesktopPage(module);
    setState(ViewState.idle);
  }

  switchDoctype({
    @required String doctype,
    @required BuildContext context,
  }) async {
    var _meta = await OfflineStorage.getMeta(doctype);

    if (_meta.docs[0].issingle == 1) {
      pushNewScreenWithRouteSettings(
        context,
        settings: RouteSettings(name: Routes.formView),
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
    pagewiseLoadController.reset();
    notifyListeners();
  }

  applyFilters(List<Filter> appliedFilters) {
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
