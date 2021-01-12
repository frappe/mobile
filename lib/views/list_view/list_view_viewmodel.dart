import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';

import 'package:frappe_app/app/router.gr.dart';
import 'package:frappe_app/services/navigation_service.dart';
import 'package:frappe_app/utils/constants.dart';

import '../../app/locator.dart';
import '../../services/api/api.dart';

import '../../utils/cache_helper.dart';
import '../../utils/helpers.dart';

class ListViewViewModel {
  getData(String doctype) async {
    var pageLoadController;
    var meta = await CacheHelper.getMeta(doctype);
    var isOnline = await verifyOnline();
    var cachedFilter = CacheHelper.getCache('${doctype}Filter');
    List filter = cachedFilter["data"] ?? [];

    // if (filter.isEmpty) {
    //   if (ConfigHelper().userId != null) {
    //     filter.add(
    //       [widget.doctype, "_assign", "like", "%${ConfigHelper().userId}%"],
    //     );
    //   }
    // }

    if (isOnline) {
      pageLoadController = PagewiseLoadController(
        pageSize: Constants.pageSize,
        pageFuture: (pageIndex) {
          return locator<Api>().fetchList(
            meta: meta.docs[0],
            doctype: doctype,
            fieldnames: generateFieldnames(
              doctype,
              meta.docs[0],
            ),
            pageLength: Constants.pageSize,
            filters: filter,
            offset: pageIndex * Constants.pageSize,
          );
        },
      );
    } else {
      pageLoadController = PagewiseLoadController(
        pageSize: Constants.offlinePageSize,
        pageFuture: (pageIndex) {
          return Future.delayed(Duration(seconds: 1), () {
            var response = CacheHelper.getCache(
              '${doctype}List',
            );
            return response["data"];
          });
        },
      );
    }

    return {
      "meta": meta,
      "filter": filter,
      "pageLoadController": pageLoadController,
    };
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
        ),
      );
    }
    ;
  }
}
