import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../form/controls/autocomplete.dart';
import '../screens/doctype_view.dart';
import '../app.dart';
import '../config/palette.dart';

import '../utils/config_helper.dart';
import '../utils/enums.dart';

class AwesomeBar extends StatefulWidget {
  @override
  _AwesomeBarState createState() => _AwesomeBarState();
}

class _AwesomeBarState extends State<AwesomeBar> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  var awesomeBarItems = [];

  @override
  void initState() {
    super.initState();
    var activeModules = ConfigHelper().activeModules;
    activeModules.keys.forEach((module) {
      awesomeBarItems.add(
        {
          "type": "Module",
          "value": module,
          "label": "Open $module",
        },
      );
    });
    activeModules.values.forEach(
      (value) {
        value.forEach(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      backgroundColor: Colors.white,
      body: FormBuilder(
        key: _fbKey,
        child: Column(
          children: [
            AutoComplete(
              hint: "Search",
              fillColor: Palette.fieldBgColor,
              itemBuilder: (context, item) {
                return ListTile(
                  title: Text(
                    item["label"],
                  ),
                );
              },
              selectionToTextTransformer: (item) {
                if (item is Map) {
                  return item["value"];
                } else {
                  return item;
                }
              },
              onSuggestionSelected: (item) {
                if (item["type"] == "Doctype") {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return CustomRouter(
                          doctype: item["value"],
                          viewType: ViewType.list,
                        );
                      },
                    ),
                  );
                } else if (item["type"] == "New Doc") {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return CustomRouter(
                          doctype: item["value"],
                          viewType: ViewType.newForm,
                        );
                      },
                    ),
                  );
                } else if (item["type"] == "Module") {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return DoctypeView(
                          item["value"],
                        );
                      },
                    ),
                  );
                }
              },
              suggestionsCallback: (query) {
                var lowercaseQuery = query.toLowerCase();
                var ss = awesomeBarItems.where((item) {
                  return (item["value"] as String)
                      .toLowerCase()
                      .contains(lowercaseQuery);
                }).toList();
                return ss;
              },
            ),
          ],
        ),
      ),
    );
  }
}
