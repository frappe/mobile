import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/views/new_doc/new_doc_view.dart';

import '../model/offline_storage.dart';
import '../utils/frappe_icon.dart';

import '../config/frappe_icons.dart';

import '../app/locator.dart';
import 'list_view/list_view.dart';

class Awesombar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.8,
        toolbarHeight: 90,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search'),
            SizedBox(
              height: 8,
            ),
            Container(
              height: 40,
              child: TextField(
                onTap: () {
                  showSearch(context: context, delegate: AwesomeSearch());
                },
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(
                      6,
                    ),
                  ),
                  fillColor: FrappePalette.grey[100],
                  prefixIcon: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: FrappeIcon(
                          FrappeIcons.search,
                          color: FrappePalette.grey[700],
                          size: 21,
                        ),
                      ),
                      Text(
                        'Search',
                        style: TextStyle(
                          fontSize: 18,
                          color: FrappePalette.grey[600],
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minHeight: 42,
                    maxHeight: 42,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AwesomeSearch extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var awesomeBarItems = [];
    var awesomeItems = OfflineStorage.getItem('awesomeItems');
    awesomeItems = awesomeItems["data"];

    // activeModules.keys.forEach((module) {
    //   awesomeBarItems.add(
    //     {
    //       "type": "Module",
    //       "value": module,
    //       "label": "Open $module",
    //     },
    //   );
    // });

    if (awesomeItems != null) {
      awesomeItems.values.forEach(
        (value) {
          (value as List).forEach(
            (v) {
              awesomeBarItems.add(
                {
                  "type": "Doctype",
                  "value": v,
                  "label": "$v List",
                },
              );
              awesomeBarItems.add(
                {
                  "type": "New Doc",
                  "value": v,
                  "label": "New $v",
                },
              );
            },
          );
        },
      );
    }

    awesomeBarItems = awesomeBarItems.where((element) {
      var lowercaseQuery = query.toLowerCase();
      return (element["value"] as String)
          .toLowerCase()
          .contains(lowercaseQuery);
    }).toList();

    return ListView.builder(
      itemCount: awesomeBarItems.length,
      itemBuilder: (_, index) {
        var item = awesomeBarItems[index];
        return ListTile(
          title: Text(item["label"]),
          onTap: () async {
            var meta = await OfflineStorage.getMeta(item["value"]);
            if (item["type"] == "Doctype") {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return CustomListView(meta: meta);
                  },
                ),
              );
            } else if (item["type"] == "New Doc") {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return NewDoc(meta: meta);
                  },
                ),
              );
            } else if (item["type"] == "Module") {
              // locator<NavigationService>().navigateTo(
              //   Routes.home,
              //   arguments: DoctypeViewArguments(
              //     module: item["value"],
              //   ),
              // );
              // TODO
            }
          },
        );
      },
    );
  }
}
