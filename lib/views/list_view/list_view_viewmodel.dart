import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:injectable/injectable.dart';

import '../../app/locator.dart';
import '../../app/router.gr.dart';

import '../../model/doctype_response.dart';
import '../../model/offline_storage.dart';

import '../../services/navigation_service.dart';
import '../../services/api/api.dart';

import '../../model/config.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';
import '../../utils/helpers.dart';

import '../../views/base_viewmodel.dart';
import '../../views/filter_list/filter_list_view.dart';

@lazySingleton
class ListViewViewModel extends BaseViewModel {
  DoctypeResponse meta;
  PagewiseLoadController pagewiseLoadController;
  Response error;
  var filters = {};
  bool showLiked = false;
  var userId = Config().userId;

  refresh() {
    pagewiseLoadController.reset();
  }

  getData(String doctype) async {
    setState(ViewState.busy);
    try {
      meta = await OfflineStorage.getMeta(doctype);
      var isOnline = await verifyOnline();

      if (isOnline) {
        pagewiseLoadController = PagewiseLoadController(
          pageSize: Constants.pageSize,
          pageFuture: (pageIndex) {
            return locator<Api>().fetchList(
              filters: FilterList.generateFilters(
                doctype,
                filters,
              ),
              meta: meta.docs[0],
              doctype: doctype,
              fieldnames: generateFieldnames(
                doctype,
                meta.docs[0],
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
            return Future.delayed(Duration(seconds: 1), () {
              var response = OfflineStorage.getItem(
                '${doctype}List',
              );
              return response["data"];
            });
          },
        );
      }
    } catch (e) {
      error = e;
    }

    setState(ViewState.idle);
  }

  onListTap({
    @required String doctype,
    @required String name,
  }) {
    {
      locator<NavigationService>().navigateTo(
        Routes.formView,
        arguments: FormViewArguments(
          doctype: doctype,
          name: name,
          meta: meta,
        ),
      );
    }
  }

  onButtonTap({
    @required String key,
    @required String value,
  }) {
    filters[key] = value;
    pagewiseLoadController.reset();
    notifyListeners();
  }

  toggleLiked(String doctype) {
    if (!showLiked) {
      filters["_liked_by"] = userId;
    } else {
      filters.remove('_liked_by');
    }
    showLiked = !showLiked;
    pagewiseLoadController.reset();
    notifyListeners();
  }

  applyFilters(Map newFilters) {
    if (newFilters != null) {
      filters = newFilters;

      pagewiseLoadController.reset();
      notifyListeners();
    }
  }

  clearFilters() {
    filters.clear();
    pagewiseLoadController.reset();
    notifyListeners();
  }
}
