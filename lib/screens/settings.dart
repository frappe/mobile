import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frappe_app/main.dart';
import 'package:frappe_app/screens/filter_list.dart';
import 'package:frappe_app/utils/backend_service.dart';
import 'package:frappe_app/utils/http.dart';
import 'package:frappe_app/widgets/custom_expansion_tile.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  var activeModules = Map<String, List>.from(
    json.decode(
      localStorage.getString("${baseUrl}activeModules"),
    ),
  );
  _handleBack() {
    localStorage.setString(
        '${baseUrl}activeModules', json.encode(activeModules));
    Navigator.of(context).pop(true);
  }

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
            children: value.map<Widget>((e) {
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
          title: Text('Settings'),
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
          future: BackendService(context).fetchList(
              fieldnames: [
                "`tabDocType`.`name`",
                "`tabDocType`.`module`",
              ],
              doctype: 'DocType',
              filters: FilterList.generateFilters('DocType', {
                "istable": 0,
                "issingle": 0,
              })),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var newMap = groupBy(snapshot.data, (obj) => obj['module']);
              return ListView(
                children: _generateChildren(newMap),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
