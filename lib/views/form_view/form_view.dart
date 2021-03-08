import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/form/controls/link_field.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/base_view.dart';
import 'package:frappe_app/views/form_view/form_view_viewmodel.dart';
import 'package:frappe_app/widgets/doc_info.dart';
import 'package:frappe_app/widgets/frappe_bottom_sheet.dart';
import 'package:overflow_view/overflow_view.dart';
import 'package:provider/provider.dart';

import '../../model/doctype_response.dart';
import '../../config/palette.dart';

import '../../app/locator.dart';
import '../../app/router.gr.dart';

import '../../services/navigation_service.dart';

import '../../utils/helpers.dart';
import '../../utils/frappe_alert.dart';
import '../../utils/indicator.dart';
import '../../utils/enums.dart';

import '../../model/config.dart';

import '../../widgets/custom_form.dart';
import '../../widgets/frappe_button.dart';
import '../../widgets/timeline.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/like_doc.dart';

class FormView extends StatelessWidget {
  final String name;
  final bool queued;
  final Map queuedData;
  final DoctypeResponse meta;

  FormView({
    @required this.meta,
    this.name,
    this.queued = false,
    this.queuedData,
  });

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(
      context,
    );
    return BaseView<FormViewViewModel>(
      onModelReady: (model) {
        model.getData(
          connectivityStatus: connectionStatus,
          queued: queued,
          queuedData: queuedData,
          doctype: meta.docs[0].name,
          name: name,
        );
      },
      onModelClose: (model) {
        model.editMode = false;
        model.error = null;
      },
      builder: (context, model, child) => model.state == ViewState.busy
          ? Scaffold(
              body: Center(
              child: CircularProgressIndicator(),
            ))
          : Builder(
              builder: (context) {
                if (model.error != null) {
                  return handleError(model.error);
                }
                var docs = model.formData["docs"];
                var docInfo = model.formData["docinfo"];

                var builderContext;
                var likedBy = docs[0]['_liked_by'] != null
                    ? json.decode(docs[0]['_liked_by'])
                    : [];
                var isLikedByUser = likedBy.contains(model.user);

                return Scaffold(
                  backgroundColor: Palette.bgColor,
                  appBar: AppBar(
                    elevation: 0.8,
                    backgroundColor: Colors.white,
                    title: Text('${meta.docs[0].name} Details'),
                    actions: [
                      if (model.editMode)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 4,
                          ),
                          child: FrappeFlatButton(
                            buttonType: ButtonType.secondary,
                            title: 'Cancel',
                            onPressed: () {
                              _fbKey.currentState.reset();
                              model.toggleEdit();
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 8,
                        ),
                        child: FrappeFlatButton(
                          buttonType: ButtonType.primary,
                          title: model.editMode ? 'Save' : 'Edit',
                          onPressed: model.editMode
                              ? () => _handleUpdate(
                                    doc: docs[0],
                                    connectionStatus: connectionStatus,
                                    meta: meta,
                                    model: model,
                                    context: context,
                                  )
                              : () {
                                  model.toggleEdit();
                                },
                        ),
                      )
                    ],
                  ),
                  body: Builder(
                    builder: (context) {
                      builderContext = context;
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              color: FrappePalette.grey[50],
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              child: Text(
                                getTitle(meta.docs[0], docs[0]) ?? "",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: FrappePalette.grey[900],
                                ),
                              ),
                            ),
                            DocInfo(docInfo),
                            CustomForm(
                              fields: meta.docs[0].fields,
                              formKey: _fbKey,
                              doc: docs[0],
                              viewType: ViewType.form,
                              editMode: model.editMode,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  _handleUpdate({
    @required Map doc,
    @required ConnectivityStatus connectionStatus,
    @required DoctypeResponse meta,
    @required FormViewViewModel model,
    @required BuildContext context,
  }) async {
    if (_fbKey.currentState.saveAndValidate()) {
      var formValue = _fbKey.currentState.value;

      try {
        await model.handleUpdate(
          connectivityStatus: connectionStatus,
          name: name,
          doctype: meta.docs[0].name,
          meta: meta,
          formValue: formValue,
          doc: doc,
          queuedData: queuedData,
        );
        FrappeAlert.infoAlert(
          title: 'Changes Saved',
          context: context,
        );
      } catch (e) {
        showErrorDialog(e, context);
      }
    }
  }
}
