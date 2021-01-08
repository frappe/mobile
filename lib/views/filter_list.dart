import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../app/locator.dart';
import '../datamodels/doctype_response.dart';
import '../services/navigation_service.dart';
import '../form/controls/control.dart';
import '../widgets/frappe_button.dart';

import '../utils/cache_helper.dart';
import '../utils/enums.dart';

class FilterList extends StatefulWidget {
  final String doctype;

  FilterList({
    @required this.doctype,
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

  List<Widget> _generateChildren(List<DoctypeField> fields, List filters) {
    fields.add(DoctypeField(
      isDefaultFilter: 1,
      fieldname: "_assign",
      options: "User",
      label: "Assigned To",
      fieldtype: "Link",
    ));
    return fields.where((field) {
      return field.inStandardFilter == 1 || field.isDefaultFilter == 1;
    }).map<Widget>(
      (field) {
        var val;
        var valObj;

        if (filters != null && filters.length > 0) {
          for (int i = 0; i < filters.length; i++) {
            if (filters[i][1] == field.fieldname) {
              val = filters[i][3];
              valObj = {field.fieldname: filters[i][3]};
            }
          }
        }

        return Column(
          children: <Widget>[
            ListTile(
              title: makeControl(field: field, value: val, doc: valObj),
            ),
            Divider(
              height: 10.0,
            ),
          ],
        );
      },
    ).toList();
  }

  _getData() async {
    var meta = await CacheHelper.getMeta(widget.doctype);
    var cachedFilter = CacheHelper.getCache('${widget.doctype}Filter');
    List filter = cachedFilter["data"] ?? [];

    return {
      "meta": meta,
      "filter": filter,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData(),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          var meta = snapshot.data["meta"];
          var filters = snapshot.data["filter"];
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
                        FilterList.clearFilters(meta.docs[0].name);
                        _fbKey.currentState.reset();
                        filters.clear();
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

                        await FilterList.generateFilters(
                          meta.docs[0].name,
                          _fbKey.currentState.value,
                        );

                        locator<NavigationService>().pop(true);
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
                  locator<NavigationService>().pop();
                },
              ),
            ),
            body: FormBuilder(
              key: _fbKey,
              child: ListView(
                padding: EdgeInsets.all(10),
                children: _generateChildren(
                  meta.docs[0].fields,
                  filters,
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            body: snapshot.hasError
                ? Center(child: Text(snapshot.error))
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          );
        }
      },
    );
  }
}
