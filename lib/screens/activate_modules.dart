import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frappe_app/app/locator.dart';
import 'package:frappe_app/services/api/api.dart';
import 'package:provider/provider.dart';

import '../screens/filter_list.dart';

import '../widgets/custom_expansion_tile.dart';

import '../config/frappe_icons.dart';
import '../config/palette.dart';

import '../utils/cache_helper.dart';
import '../utils/config_helper.dart';
import '../utils/enums.dart';
import '../utils/frappe_icon.dart';
import '../utils/helpers.dart';

class ActivateModules extends StatefulWidget {
  @override
  _ActivateModulesState createState() => _ActivateModulesState();
}

class _ActivateModulesState extends State<ActivateModules> {
  var activeModules = {};

  @override
  void initState() {
    super.initState();

    if (ConfigHelper().activeModules != null) {
      activeModules = ConfigHelper().activeModules;
    }
  }

  Future _getData() async {
    var connectionStatus = Provider.of<ConnectivityStatus>(
      context,
    );
    var isOnline = await verifyOnline();
    if ((connectionStatus == null ||
            connectionStatus == ConnectivityStatus.offline) &&
        !isOnline) {
      var response = await CacheHelper.getCache('DocTypeList');
      response = response["data"];
      if (response == null) {
        throw Response(statusCode: HttpStatus.serviceUnavailable);
      }
      return response;
    } else {
      var meta = await locator<Api>().getDoctype('Doctype');
      var doctypeDoc = meta.docs[0];
      var deskSideBarItems = await locator<Api>().getDeskSideBarItems();
      var deskModules = deskSideBarItems.message.modules;

      var doctypes = await locator<Api>().fetchList(
        fieldnames: [
          "`tabDocType`.`name`",
          "`tabDocType`.`module`",
        ],
        doctype: 'DocType',
        meta: doctypeDoc,
        filters: await FilterList.generateFilters(
          'DocType',
          {
            "istable": 0,
            "issingle": 0,
          },
        ),
      );

      doctypes.forEach((doctype) {
        var deskModule = deskModules.firstWhere(
          (deskModule) => doctype["module"] == deskModule.module,
          orElse: () => null,
        );

        if (deskModule != null) {
          doctype["module_label"] = deskModule.label;
        } else {
          doctype["module_label"] = doctype["module"];
        }
      });

      return doctypes;
    }
  }

  _handleBack() async {
    await ConfigHelper.set(
      '${ConfigHelper().primaryCacheKey}activeModules',
      activeModules,
    );

    Navigator.of(context).pop(true);
  }

  var doctypes = [];

  List<Widget> _generateChildren(allModules) {
    List<Widget> w = [];
    allModules.forEach(
      (key, value) {
        var headerVal;
        if (activeModules[key] != null && activeModules[key].isNotEmpty) {
          if (activeModules[key].length == allModules[key].length) {
            headerVal = true;
          } else {
            headerVal = null;
          }
        } else {
          headerVal = false;
        }
        w.add(
          CustomExpansionTile(
            title: Text('$key'),
            leadingArrow: true,
            trailing: Checkbox(
              onChanged: (b) {
                headerVal = b;
                if (b == null) {
                  b = false;
                }
                if (b) {
                  if (activeModules[key] == null) {
                    activeModules[key] = [];
                  } else {
                    activeModules[key].clear();
                  }
                  allModules[key].forEach(
                    (m) => activeModules[key].add(
                      m["name"],
                    ),
                  );
                } else {
                  activeModules[key].clear();
                }
                setState(() {});
              },
              tristate: true,
              value: headerVal,
            ),
            children: sortBy(value, "name", Order.asc).map<Widget>((e) {
              return ListTile(
                title: Text('${e["name"]}'),
                trailing: Checkbox(
                  value: activeModules[key] != null
                      ? activeModules[key].contains(e["name"])
                      : false,
                  onChanged: (b) {
                    if (b) {
                      if (activeModules[key] != null) {
                        activeModules[key].add(e["name"]);
                      } else {
                        activeModules[key] = [e["name"]];
                      }
                    } else {
                      activeModules[key].remove(e["name"]);
                    }
                    setState(() {});
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );

    return w;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Activate Modules'),
          actions: [
            IconButton(
              icon: FrappeIcon(
                FrappeIcons.search,
                color: Palette.iconColor,
              ),
              onPressed: () async {
                var nav = await showSearch(
                  context: context,
                  delegate: CustomSearch(
                    doctypes,
                    activeModules,
                  ),
                );

                if (nav) {
                  setState(() {});
                }
              },
            ),
          ],
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              _handleBack();
            },
          ),
        ),
        body: FutureBuilder(
          future: _getData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              doctypes = snapshot.data;
              var newMap = groupBy(snapshot.data, (obj) => obj['module_label']);
              return ListView(
                children: _generateChildren(newMap),
              );
            } else if (snapshot.hasError) {
              return handleError(snapshot.error);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

class CustomSearch extends SearchDelegate {
  final List doctypes;
  final activeModules;

  CustomSearch(
    this.doctypes,
    this.activeModules,
  );

  @override
  String get searchFieldLabel => "Search doctypes";

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
        close(context, true);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        close(context, true);
        return false;
      },
      child: DoctypeSuggestions(
        doctypes: doctypes,
        activeModules: activeModules,
        query: query,
      ),
    );
  }
}

class DoctypeSuggestions extends StatefulWidget {
  final List doctypes;
  final activeModules;
  final String query;

  const DoctypeSuggestions({
    Key key,
    this.doctypes,
    this.activeModules,
    this.query,
  }) : super(key: key);

  @override
  _DoctypeSuggestionsState createState() => _DoctypeSuggestionsState();
}

class _DoctypeSuggestionsState extends State<DoctypeSuggestions> {
  @override
  Widget build(BuildContext context) {
    var filteredDoctypes = widget.doctypes
        .where((doctype) =>
            doctype["name"].toLowerCase().contains(widget.query.toLowerCase()))
        .toList();
    return ListView(
      children: sortBy(filteredDoctypes, 'name', Order.asc).map((doctype) {
        return ListTile(
          title: Text(doctype["name"]),
          subtitle: Text(doctype["module"]),
          trailing: Checkbox(
            value: widget.activeModules[doctype["module"]] != null
                ? widget.activeModules[doctype["module"]]
                    .contains(doctype["name"])
                : false,
            onChanged: (b) {
              if (b) {
                if (widget.activeModules[doctype["module"]] != null) {
                  widget.activeModules[doctype["module"]].add(doctype["name"]);
                } else {
                  widget.activeModules[doctype["module"]] = [doctype["name"]];
                }
              } else {
                widget.activeModules[doctype["module"]].remove(doctype["name"]);
              }
              setState(() {});
            },
          ),
        );
      }).toList(),
    );
  }
}
