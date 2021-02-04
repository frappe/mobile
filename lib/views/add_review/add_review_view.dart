import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../views/add_review/add_review_viewmodel.dart';
import '../../views/base_view.dart';

import '../../app/locator.dart';

import '../../model/doctype_response.dart';

import '../../services/api/api.dart';
import '../../services/navigation_service.dart';

import '../../utils/enums.dart';

import '../../widgets/custom_form.dart';
import '../../widgets/frappe_button.dart';

class AddReview extends StatelessWidget {
  final String doctype;
  final String name;
  final DoctypeDoc meta;
  final Map doc;
  final Map docInfo;

  AddReview({
    Key key,
    @required this.doctype,
    @required this.name,
    @required this.meta,
    @required this.doc,
    @required this.docInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
    return BaseView<AddReviewViewModel>(
      onModelReady: (model) {
        model.getReviewFormFields(
          doc: doc,
          docInfo: docInfo,
          meta: meta,
        );
      },
      builder: (context, model, child) => model.state == ViewState.busy
          ? Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Scaffold(
              appBar: AppBar(
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 4,
                    ),
                    child: FrappeFlatButton(
                      onPressed: () async {
                        if (_fbKey.currentState.saveAndValidate()) {
                          var formValue = _fbKey.currentState.value;
                          await locator<Api>().addReview(
                            doctype,
                            name,
                            formValue,
                          );

                          locator<NavigationService>().pop(true);
                        }
                      },
                      buttonType: ButtonType.primary,
                      title: 'Submit',
                    ),
                  )
                ],
              ),
              body: CustomForm(
                fields: model.fields,
                formKey: _fbKey,
                viewType: ViewType.newForm,
              ),
            ),
    );
  }
}
