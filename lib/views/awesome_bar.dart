import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/datamodels/doctype_response.dart';

import '../services/navigation_service.dart';
import '../form/controls/autocomplete.dart';
import '../config/palette.dart';

import '../app/locator.dart';
import '../app/router.gr.dart';

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
              doctypeField: DoctypeField(label: "Search"),
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
                  locator<NavigationService>().navigateTo(
                    Routes.customRouter,
                    arguments: CustomRouterArguments(
                      doctype: item["value"],
                      viewType: ViewType.list,
                    ),
                  );
                } else if (item["type"] == "New Doc") {
                  locator<NavigationService>().navigateTo(
                    Routes.customRouter,
                    arguments: CustomRouterArguments(
                      doctype: item["value"],
                      viewType: ViewType.newForm,
                    ),
                  );
                } else if (item["type"] == "Module") {
                  locator<NavigationService>().navigateTo(
                    Routes.doctypeView,
                    arguments: DoctypeViewArguments(
                      module: item["value"],
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
