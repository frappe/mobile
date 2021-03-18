import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../model/doctype_response.dart';
import '../../app/locator.dart';

import '../../views/base_view.dart';
import '../../views/share/share_viewmodel.dart';

import '../../services/api/api.dart';
import '../../services/navigation_service.dart';

import '../../form/controls/control.dart';
import '../../form/controls/link_field.dart';

import '../../utils/frappe_alert.dart';
import '../../utils/enums.dart';

import '../../widgets/custom_expansion_tile.dart';
import '../../widgets/custom_form.dart';
import '../../widgets/frappe_button.dart';

class Share extends StatelessWidget {
  final String doctype;
  final Map docInfo;
  final String name;

  Share({
    Key key,
    @required this.doctype,
    @required this.docInfo,
    @required this.name,
  }) : super(key: key);

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return BaseView<ShareViewModel>(
      onModelReady: (model) {
        model.docInfo = docInfo;
      },
      builder: (context, model, child) => WillPopScope(
        onWillPop: () async {
          locator<NavigationService>().pop(true);
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
              ),
              onPressed: () {
                locator<NavigationService>().pop(true);
              },
            ),
          ),
          body: Builder(
            builder: (context) {
              return ListView(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: FormBuilder(
                          child: LinkField(
                              key: Key(model.selectedUser),
                              prefixIcon: Icon(Icons.search),
                              fillColor: Colors.white,
                              doctypeField: DoctypeField(
                                options: 'User',
                                label: 'Share this document with',
                                fieldname: 'user',
                              ),
                              doc: {
                                'user': model.selectedUser,
                              },
                              onSuggestionSelected: (item) {
                                model.selectUser(item["value"]);
                              }),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FrappeFlatButton(
                            buttonType: ButtonType.primary,
                            onPressed: model.selectedUser != null
                                ? () async {
                                    if (_fbKey.currentState.saveAndValidate()) {
                                      var formValue = _fbKey.currentState.value;
                                      var req = {
                                        'user': model.selectedUser,
                                        ...formValue,
                                      };
                                      var user = model.selectedUser;

                                      await model.share(
                                        data: req,
                                        doctype: doctype,
                                        name: name,
                                      );

                                      FrappeAlert.infoAlert(
                                        title: 'Shared with $user',
                                        context: context,
                                      );
                                    }
                                  }
                                : null,
                            title: "Add",
                          ),
                        ),
                      )
                    ],
                  ),
                  if (model.selectedUser != null)
                    CustomForm(
                      fields: model.fields,
                      formKey: _fbKey,
                      viewType: ViewType.newForm,
                      editMode: true,
                    ),
                  ..._generateChildren(
                    shares: model.docInfo["shared"],
                    model: model,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _generateChildren({
    @required List shares,
    @required ShareViewModel model,
  }) {
    List<Widget> fields = [];
    bool isSharedToEveryone = shares.any((share) => share["everyone"] == 1);

    if (!isSharedToEveryone) {
      shares.insert(0, {
        "everyone": 1,
        "read": 0,
        "write": 0,
        "share": 0,
        "user": "",
      });
    }

    shares.asMap().entries.forEach(
      (entry) {
        var share = entry.value;

        if (share["everyone"] == 1) {
          fields.insert(
            0,
            CustomExpansionTile(
              initiallyExpanded: true,
              title: Text(
                "Everyone",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                ...model.fields.map<Widget>(
                  (w) {
                    return makeControl(
                      field: w,
                      value: share[w.fieldname],
                      onChanged: (val) async {
                        // await locator<Api>().setPermission(
                        //   doctype,
                        //   name,
                        //   {
                        //     "everyone": 1,
                        //     "permission_to": w.fieldname,
                        //     "value": val,
                        //     "user": ""
                        //   },
                        // );
                        model.updateDocInfo(
                          doctype: doctype,
                          name: name,
                        );
                      },
                    );
                  },
                ).toList()
              ],
            ),
          );
        } else {
          fields.add(
            CustomExpansionTile(
              title: Text(
                share["user"] ?? "",
              ),
              children: [
                ...model.fields.map<Widget>(
                  (w) {
                    return makeControl(
                      field: w,
                      value: share[w.fieldname],
                      onChanged: (val) async {
                        // await locator<Api>().setPermission(
                        //   doctype,
                        //   name,
                        //   {
                        //     "everyone": 0,
                        //     "user": share["user"],
                        //     "permission_to": w.fieldname,
                        //     "value": val,
                        //   },
                        // );
                        model.updateDocInfo(
                          doctype: doctype,
                          name: name,
                        );
                      },
                    );
                  },
                ).toList()
              ],
            ),
          );
        }
      },
    );

    return fields;
  }
}
