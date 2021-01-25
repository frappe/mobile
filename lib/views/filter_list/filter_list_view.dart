import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../views/filter_list/filter_list_viewmodel.dart';
import '../../app/locator.dart';
import '../../datamodels/doctype_response.dart';
import '../../services/navigation_service.dart';
import '../../form/controls/control.dart';
import '../../widgets/frappe_button.dart';

import '../../utils/enums.dart';

class FilterList extends StatefulWidget {
  final String doctype;
  final Map filters;

  FilterList({
    @required this.doctype,
    @required this.filters,
  });

  static List generateFilters(String doctype, Map filters) {
    var transformedFilters = [];

    filters.forEach((k, v) {
      if (v != null) {
        if ((k == '_assign' || k == '_liked_by') && v != '') {
          transformedFilters.add([doctype, k, "like", "%$v%"]);
        } else {
          if (v != "") {
            transformedFilters.add([doctype, k, "=", v]);
          }
        }
      }
    });

    return transformedFilters;
  }

  @override
  _FilterListState createState() => _FilterListState();
}

class _FilterListState extends State<FilterList> {
  GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FilterListViewModel().getData(
        widget.doctype,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          var meta = snapshot.data["meta"];

          return Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: _bottomBar(
              meta: meta,
              filters: widget.filters,
            ),
            appBar: _appBar(),
            body: FormBuilder(
              key: _fbKey,
              child: ListView(
                padding: EdgeInsets.all(10),
                children: _generateChildren(
                  meta.docs[0].fields,
                  widget.filters,
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

  List<Widget> _generateChildren(List<DoctypeField> fields, Map filters) {
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
          val = filters[field.fieldname];
          valObj = {field.fieldname: val};
        }

        return Column(
          children: <Widget>[
            ListTile(
              title: makeControl(
                field: field,
                value: val,
                doc: valObj,
              ),
            ),
            Divider(
              height: 10.0,
            ),
          ],
        );
      },
    ).toList();
  }

  Widget _bottomBar({
    @required DoctypeResponse meta,
    @required Map filters,
  }) {
    return Container(
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
                _fbKey.currentState.reset();
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
                var formVal = _fbKey.currentState.value;
                var formValClone = {
                  ...formVal,
                };

                formValClone.removeWhere((key, val) => val == null);

                locator<NavigationService>().pop(formValClone);
              },
              title: 'Apply',
            ),
            Spacer()
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return AppBar(
      elevation: 0.5,
      leading: IconButton(
        icon: Icon(
          Icons.close,
        ),
        onPressed: () {
          locator<NavigationService>().pop();
        },
      ),
    );
  }
}
