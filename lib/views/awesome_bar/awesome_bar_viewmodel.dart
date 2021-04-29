import 'package:flutter/material.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/model/offline_storage.dart';
import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:frappe_app/views/list_view/list_view.dart';
import 'package:frappe_app/views/new_doc/new_doc_view.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AwesomBarViewModel extends BaseViewModel {
  bool hasFocus = false;
  ErrorResponse? error;
  List<AwesomeBarItem> awesomeBarItems = [];
  List<AwesomeBarItem> filteredAwesomeBarItems = [];
  // bool recentSearchesMode = true;
  // List<AwesomeBarItem> recentSearches = [];

  init() {
    error = null;
    initAwesomeBarItems();
    // getRecentItems();

    // if (recentSearches.isEmpty) {
    //   recentSearchesMode = false;
    // }
  }

  toggleFocus(bool _hasFocus) {
    hasFocus = _hasFocus;
    notifyListeners();
  }

  refresh() {
    error = null;
    notifyListeners();
  }

  initAwesomeBarItems() {
    var awesomeItems = OfflineStorage.getItem('awesomeItems')["data"];

    if (awesomeItems != null) {
      awesomeItems.values.forEach(
        (value) {
          (value as List).forEach(
            (v) {
              awesomeBarItems.add(AwesomeBarItem(
                type: "Doctype",
                value: v,
                label: "$v List",
              ));
              awesomeBarItems.add(AwesomeBarItem(
                type: "NewDoc",
                value: v,
                label: "New $v",
              ));
            },
          );
        },
      );

      filteredAwesomeBarItems =
          awesomeBarItems.where((element) => true).toList();
    }
  }

  // addToRecent(AwesomeBarItem awesomeBarItem) {
  //   var recentItems = OfflineStorage.getItem('recentSearches')["data"];
  //   if (recentItems != null) {
  //     recentItems.add(awesomeBarItem.toJson());
  //   } else {
  //     recentItems = [awesomeBarItem.toJson()];
  //   }
  //   OfflineStorage.putItem('recentSearches', recentItems);
  // }

  // getRecentItems() {
  //   List recentItemsJson =
  //       OfflineStorage.getItem('recentSearches')["data"] ?? [];
  //   recentSearches = recentItemsJson
  //       .map(
  //         (recentItem) => AwesomeBarItem.fromJson(
  //           Map<String, dynamic>.from(
  //             recentItem,
  //           ),
  //         ),
  //       )
  //       .toList();
  // }

  onItemTap({
    required AwesomeBarItem awesomeBarItem,
    required BuildContext context,
  }) async {
    // addToRecent(awesomeBarItem);
    try {
      var meta = await OfflineStorage.getMeta(
        awesomeBarItem.value,
      );
      error = null;
      if (awesomeBarItem.type == "Doctype") {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return CustomListView(
                meta: meta,
                module: meta.docs[0].module,
              );
            },
          ),
        );
      } else if (awesomeBarItem.type == "NewDoc") {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return NewDoc(meta: meta);
            },
          ),
        );
      }
      // } else if (item["type"] == "Module") {
      // locator<NavigationService>().navigateTo(
      //   Routes.home,
      //   arguments: DoctypeViewArguments(
      //     module: item["value"],
      //   ),
      // );
      // TODO
    } catch (e) {
      error = e as ErrorResponse;
    }
  }

  filterSearchItems(String searchText) {
    filteredAwesomeBarItems = awesomeBarItems
        .where(
          (item) => item.label.toLowerCase().contains(
                searchText.toLowerCase(),
              ),
        )
        .toList();
    notifyListeners();
  }
}

class AwesomeBarItem {
  late String type;
  late String value;
  late String label;

  AwesomeBarItem(
      {required this.type, required this.value, required this.label});

  AwesomeBarItem.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    value = json['value'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['value'] = this.value;
    data['label'] = this.label;
    return data;
  }
}
