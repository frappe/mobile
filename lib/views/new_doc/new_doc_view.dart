import 'package:frappe_app/views/new_doc/new_doc_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../datamodels/doctype_response.dart';

import '../../utils/enums.dart';

import '../../widgets/custom_form.dart';
import '../../widgets/frappe_button.dart';

class NewDoc extends StatefulWidget {
  final String doctype;

  const NewDoc({
    @required this.doctype,
  });

  @override
  _NewDocState createState() => _NewDocState();
}

class _NewDocState extends State<NewDoc> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
    var connectionStatus = Provider.of<ConnectivityStatus>(
      context,
    );

    return FutureBuilder<DoctypeResponse>(
      future: NewDocViewModel().getData(widget.doctype),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          var meta = snapshot.data;
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
                    onPressed: () => NewDocViewModel().saveDoc(
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
        } else {
          return Scaffold(
            body: snapshot.hasError
                ? Center(
                    child: Text(snapshot.error),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          );
        }
      },
    );
  }
}
