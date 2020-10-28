import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../form/controls/control.dart';

import '../widgets/frappe_button.dart';

import '../utils/cache_helper.dart';
import '../utils/enums.dart';

class FilterList extends StatefulWidget {
  final Function filterCallback;
  final Map wireframe;
  final String appBarTitle;
  final List filters;

  FilterList({
    this.filterCallback,
    @required this.wireframe,
    @required this.appBarTitle,
    this.filters,
  });

  static int getFieldFilterIndex(List filters, String field) {
    int idx;
    for (int i = 0; i < filters.length; i++) {
      if (filters[i][1] == field) {
        idx = i;
        break;
      }
    }

    return idx;
  }

  static clearFilters(String doctype) {
    CacheHelper.remove(
      "${doctype}Filter",
    );
  }

  static Future<List> generateFilters(String doctype, Map filters) async {
    var transformedFilters;
    var kIdx;
    var cacheKey = '${doctype}Filter';
    var cachedFilters = await CacheHelper.getCache(cacheKey);
    cachedFilters = cachedFilters["data"];
    if (cachedFilters != null) {
      transformedFilters = cachedFilters;
    } else {
      transformedFilters = [];
    }

    filters.forEach((k, v) {
      if (v != null) {
        if (k == '_assign' && v != '') {
          kIdx = getFieldFilterIndex(transformedFilters, k);
          if (kIdx != null) {
            transformedFilters.removeAt(kIdx);
          }
          transformedFilters.add([doctype, k, "like", "%$v%"]);
        } else {
          if (v != "") {
            kIdx = getFieldFilterIndex(transformedFilters, k);
            if (kIdx != null) {
              transformedFilters.removeAt(kIdx);
            }
            transformedFilters.add([doctype, k, "=", v]);
          }
        }
      }
    });

    await CacheHelper.putCache(
      cacheKey,
      transformedFilters,
    );

    return transformedFilters;
  }

  @override
  _FilterListState createState() => _FilterListState();
}

class _FilterListState extends State<FilterList> {
  GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  List<Widget> _generateChildren(var fields) {
    return fields.where((field) {
      return field["in_standard_filter"] == 1 ||
          field["is_default_filter"] == 1;
    }).map<Widget>(
      (field) {
        var val;

        if (widget.filters != null && widget.filters.length > 0) {
          for (int i = 0; i < widget.filters.length; i++) {
            if (widget.filters[i][1] == field["fieldname"]) {
              val = widget.filters[i][3];
            }
          }
        }

        return Column(
          children: <Widget>[
            ListTile(
              title: makeControl(field: field, value: val),
            ),
            Divider(
              height: 10.0,
            ),
          ],
        );
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        height: 60,
        child: BottomAppBar(
          color: Colors.white,
          child: Row(
            children: [
              Spacer(),
              FrappeFlatButton(
                minWidth: 120.0,
                buttonType: ButtonType.secondary,
                title: 'Clear All',
                onPressed: () {
                  FilterList.clearFilters(widget.wireframe["name"]);
                  _fbKey.currentState.reset();
                  widget.filters.clear();
                  setState(() {});
                },
              ),
              SizedBox(
                width: 10,
              ),
              FrappeFlatButton(
                minWidth: 120.0,
                buttonType: ButtonType.primary,
                onPressed: () async {
                  _fbKey.currentState.save();

                  var filters = await FilterList.generateFilters(
                    widget.wireframe["name"],
                    _fbKey.currentState.value,
                  );

                  Navigator.of(context).pop();

                  widget.filterCallback(filters);
                },
                title: 'Apply',
              ),
              Spacer()
            ],
          ),
        ),
      ),
      appBar: AppBar(
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.close,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FormBuilder(
        key: _fbKey,
        child: ListView(
          padding: EdgeInsets.all(10),
          children: _generateChildren(
            widget.wireframe["fields"],
          ),
        ),
      ),
    );
  }
}
