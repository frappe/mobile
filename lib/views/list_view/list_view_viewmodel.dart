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
  late List<DoctypeField> sortableFields;
  late DoctypeField sortField;
  late String sortOrder;

  refresh() {
    pagewiseLoadController?.reset();
  }

  updateSort(Map sort) {
    sortField = sort["field"] as DoctypeField;
    sortOrder = sort["order"];
    getData();
  }

  getSortableFields() {
    List<DoctypeField> _sortableFields = [];
    var _fields = meta.docs[0].fields.where((element) => true).toList();

    _fields.addAll([
      DoctypeField(
        fieldname: 'idx',
        label: "Most Used",
        reqd: 1,
      ),
      DoctypeField(
        fieldname: 'modified',
        label: "Last Modified On",
        reqd: 1,
      ),
      DoctypeField(
        fieldname: 'creation',
        label: "Created On",
        reqd: 1,
      ),
    ]);

    var metaSortField = meta.docs[0].sortField!.split(",")[0].split(" ")[0];
    var metaSortDoctypeField = _fields.firstWhere(
      (field) => field.fieldname == metaSortField,
      orElse: () => DoctypeField(
        fieldname: metaSortField,
        label: metaSortField.toUpperCase(),
      ),
    );
    _sortableFields.add(metaSortDoctypeField);

    _fields.forEach(
      (field) {
        if ((field.bold == 1 || field.reqd == 1) &&
            field.fieldname != metaSortField) {
          _sortableFields.add(field);
        }
      },
    );

    sortableFields = _sortableFields;
    sortField = sortableFields[0];
    sortOrder = meta.docs[0].sortOrder?.toLowerCase() ?? "desc";
  }

  bool get hasError => error != null;

  init() {
    var userSettings = jsonDecode(meta.userSettings);
    var userSettingsList = userSettings["List"];
    var userSettingsReport = userSettings["Report"];

    if (userSettingsList != null &&
        (userSettingsList["filters"] as List).isNotEmpty) {
      (userSettingsList["filters"] as List).forEach(
        (listFilter) {
          filters.add(
            Filter(
              field: meta.docs[0].fields.firstWhere(
                (metaField) => metaField.fieldname == listFilter[1],
                orElse: () {
                  return DoctypeField(
                    fieldname: listFilter[1],
                    label: listFilter[1],
                  );
                },
              ),
              filterOperator: FilterOperator(
                label: Constants.filterOperatorLabelMapping[listFilter[2]]!,
                value: listFilter[2],
              ),
              value: listFilter[3].toString(),
            ),
          );
        },
      );

      if (userSettingsList["sort_by"] != null) {
        sortField = meta.docs[0].fields.firstWhere(
          (metaField) => metaField.fieldname == userSettingsList["sort_by"],
          orElse: () {
            return DoctypeField(
              fieldname: userSettingsList["sort_by"],
              label: userSettingsList["sort_by"],
            );
          },
        );
      }

      if (userSettingsList["sort_order"] != null) {
        sortOrder = userSettingsList["sort_order"];
      }
    } else if (userSettingsReport != null &&
        (userSettingsReport["filters"] as List).isNotEmpty) {
      (userSettingsReport["filters"] as List).forEach(
        (reportFilter) {
          filters.add(
            Filter(
              field: meta.docs[0].fields.firstWhere(
                (metaField) => metaField.fieldname == reportFilter[1],
                orElse: () {
                  return DoctypeField(
                    fieldname: reportFilter[1],
                    label: reportFilter[1],
                  );
                },
              ),
              filterOperator: FilterOperator(
                label: Constants.filterOperatorLabelMapping[reportFilter[2]]!,
                value: reportFilter[2],
              ),
              value: reportFilter[3].toString(),
            ),
          );
        },
      );

      if (userSettingsReport["sort_by"] != null) {
        sortField = meta.docs[0].fields.firstWhere(
          (metaField) => metaField.fieldname == userSettingsReport["sort_by"],
          orElse: () {
            return DoctypeField(
              fieldname: userSettingsReport["sort_by"],
              label: userSettingsReport["sort_by"],
            );
          },
        );
      }

      if (userSettingsReport["sort_order"] != null) {
        sortOrder = userSettingsReport["sort_order"];
      }
    }
  }

  getData() async {
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
                meta.docs[0].name,
                filter.field.fieldname,
                filter.filterOperator.value,
                value,
              ];
            }).toList();

            return locator<Api>().fetchList(
              filters: transformedFilters,
              meta: meta.docs[0],
              doctype: meta.docs[0].name,
              orderBy:
                  '`tab${meta.docs[0].name}`.`${sortField.fieldname}` $sortOrder',
              fieldnames: generateFieldnames(
                meta.docs[0].name,
                meta.docs[0],
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
                  '${meta.docs[0].name}List',
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
          meta: meta.docs[0],
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
          meta: _meta.docs[0],
          name: _meta.docs[0].name,
        ),
        withNavBar: true,
      );
    } else {
      Navigator.of(context).pop();
      meta = _meta;
      getData();
    }
  }

  removeFilter(int index) {
    filters.removeAt(index);
    getData();
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
        getData();
      } else {
        filters = [];
        getData();
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
