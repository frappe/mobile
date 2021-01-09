import 'dart:convert';
import 'dart:typed_data';

import 'package:frappe_app/utils/cache_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../datamodels/doctype_response.dart';

import '../app/locator.dart';
import '../app/router.gr.dart';

import '../services/api/api.dart';
import '../services/navigation_service.dart';

import '../utils/enums.dart';
import '../utils/frappe_alert.dart';
import '../utils/queue_helper.dart';
import '../utils/helpers.dart';

import '../widgets/custom_form.dart';
import '../widgets/frappe_button.dart';

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

    return FutureBuilder(
      future: CacheHelper.getMeta(widget.doctype),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          var meta = (snapshot.data as DoctypeResponse);
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
                    onPressed: () async {
                      if (_fbKey.currentState.saveAndValidate()) {
                        var formValue = _fbKey.currentState.value;

                        formValue.forEach((key, value) {
                          if (value is Uint8List) {
                            formValue[key] =
                                "data:image/png;base64,${base64.encode(value)}";
                          }
                        });

                        var isOnline = await verifyOnline();
                        if ((connectionStatus == null ||
                                connectionStatus ==
                                    ConnectivityStatus.offline) &&
                            !isOnline) {
                          var qc = QueueHelper.getQueueContainer();
                          var queueLength = qc.length;
                          var qObj = {
                            "type": "Create",
                            "doctype": meta.docs[0].name,
                            "title": hasTitle(meta.docs[0])
                                ? formValue[meta.docs[0].titleField] ??
                                    "${meta.docs[0].name} ${queueLength + 1}"
                                : "${meta.docs[0].name} ${queueLength + 1}",
                            "data": [formValue],
                          };
                          await QueueHelper.add(qObj);

                          FrappeAlert.infoAlert(
                            title: 'No Internet Connection',
                            subtitle: 'Added to Queue',
                            context: context,
                          );
                          locator<NavigationService>().pop();
                        } else {
                          try {
                            var response = await locator<Api>().saveDocs(
                              meta.docs[0].name,
                              formValue,
                            );
                            locator<NavigationService>().pushReplacement(
                              Routes.formView,
                              arguments: FormViewArguments(
                                doctype: meta.docs[0].name,
                                name: response.data["docs"][0]["name"],
                              ),
                            );
                          } catch (e) {
                            showErrorDialog(e, context);
                          }
                        }
                      }
                    },
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
