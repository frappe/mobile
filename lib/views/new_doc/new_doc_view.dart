import 'package:frappe_app/views/base_view.dart';
import 'package:frappe_app/views/new_doc/new_doc_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../datamodels/doctype_response.dart';

import '../../utils/enums.dart';

import '../../widgets/custom_form.dart';
import '../../widgets/frappe_button.dart';

class NewDoc extends StatelessWidget {
  final String doctype;
  final DoctypeResponse meta;

  const NewDoc({
    @required this.doctype,
    @required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
    var connectionStatus = Provider.of<ConnectivityStatus>(
      context,
    );

    return BaseView<NewDocViewModel>(
      builder: (context, model, child) => Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: Text("New ${meta.docs[0].name}"),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 4,
                  ),
                  child: FrappeFlatButton(
                    buttonType: ButtonType.primary,
                    title: 'Save',
                    onPressed: () => model.saveDoc(
                      connectionStatus: connectionStatus,
                      formKey: _fbKey,
                      meta: meta,
                      context: context,
                    ),
                  ),
                ),
              ],
            ),
            body: CustomForm(
              formKey: _fbKey,
              fields: meta.docs[0].fields,
              viewType: ViewType.newForm,
            ),
          );
        },
      ),
    );
  }
}
