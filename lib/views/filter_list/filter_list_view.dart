import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../app/locator.dart';
import '../../datamodels/doctype_response.dart';
import '../../services/navigation_service.dart';
import '../../utils/enums.dart';

import '../../views/base_view.dart';
import '../../views/filter_list/filter_list_viewmodel.dart';

import '../../widgets/frappe_button.dart';
import '../../widgets/custom_form.dart';

class FilterList extends StatelessWidget {
  final String doctype;
  final Map filters;
  final DoctypeResponse meta;

  FilterList({
    @required this.doctype,
    @required this.filters,
    @required this.meta,
  });

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return BaseView<FilterListViewModel>(
      onModelReady: (model) {
        model.getFieldsWithValue(
          meta.docs[0].fields,
          filters,
        );
      },
      builder: (context, model, child) => model.state == ViewState.busy
          ? Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Builder(
              builder: (context) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  bottomNavigationBar: _bottomBar(
                    meta: meta,
                    filters: filters,
                    model: model,
                  ),
                  appBar: _appBar(),
                  body: CustomForm(
                    fields: model.filterFields,
                    formKey: _fbKey,
                    doc: model.doc,
                  ),
                );
              },
            ),
    );
  }

  Widget _bottomBar({
    @required DoctypeResponse meta,
    @required Map filters,
    @required FilterListViewModel model,
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
                model.clearFields();
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
}
