import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../form/controls/control.dart';
import '../form/controls/link_field.dart';

import '../utils/backend_service.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';

import '../widgets/custom_expansion_tile.dart';
import '../widgets/custom_form.dart';
import '../widgets/frappe_button.dart';

class Share extends StatefulWidget {
  final String doctype;
  final Map docInfo;
  final String name;

  const Share({
    Key key,
    @required this.doctype,
    @required this.docInfo,
    @required this.name,
  }) : super(key: key);

  @override
  _ShareState createState() => _ShareState();
}

class _ShareState extends State<Share> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  var wireframe;
  var selectedUser;
  Future _futureVal;
  var docInfo;

  @override
  void initState() {
    super.initState();
    _futureVal = Future.value(
      {
        "docinfo": widget.docInfo,
      },
    );
    wireframe = [
      {
        "fieldname": 'read',
        "fieldtype": 'Check',
        "label": 'Can Read',
      },
      {
        "fieldname": 'write',
        "fieldtype": 'Check',
        "label": 'Can Write',
      },
      {
        "fieldname": 'share',
        "fieldtype": 'Check',
        "label": 'Can Share',
      },
    ];
  }

  List<Widget> _generateChildren(
    List shares,
  ) {
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
                ...wireframe.map<Widget>(
                  (w) {
                    return makeControl(
                      field: w,
                      value: share[w["fieldname"]],
                      onChanged: (val) async {
                        await BackendService.setPermission(
                          widget.doctype,
                          widget.name,
                          {
                            "everyone": 1,
                            "permission_to": w["fieldname"],
                            "value": val,
                            "user": ""
                          },
                        );
                        _refresh();
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
                ...wireframe.map<Widget>(
                  (w) {
                    return makeControl(
                      field: w,
                      value: share[w["fieldname"]],
                      onChanged: (val) async {
                        await BackendService.setPermission(
                          widget.doctype,
                          widget.name,
                          {
                            "everyone": 0,
                            "user": share["user"],
                            "permission_to": w["fieldname"],
                            "value": val,
                          },
                        );
                        _refresh();
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

  void _refresh() {
    setState(() {
      _futureVal = BackendService.getDocinfo(widget.doctype, widget.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ),
        body: FutureBuilder(
          future: _futureVal,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              docInfo = snapshot.data["docinfo"];
              return ListView(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: FormBuilder(
                          child: LinkField(
                              key: Key(selectedUser),
                              value: selectedUser,
                              prefixIcon: Icon(Icons.search),
                              fillColor: Colors.white,
                              doctype: 'User',
                              refDoctype: 'Issue',
                              hint: 'Share this document with',
                              onSuggestionSelected: (item) {
                                setState(() {
                                  selectedUser = item["value"];
                                });
                              }),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FrappeFlatButton(
                            buttonType: ButtonType.primary,
                            onPressed: selectedUser != null
                                ? () async {
                                    if (_fbKey.currentState.saveAndValidate()) {
                                      var formValue = _fbKey.currentState.value;
                                      var req = {
                                        'user': selectedUser,
                                        ...formValue,
                                      };

                                      await BackendService.shareAdd(
                                        widget.doctype,
                                        widget.name,
                                        req,
                                      );
                                    }
                                    showSnackBar(
                                      'Shared with $selectedUser',
                                      context,
                                    );
                                    selectedUser = null;
                                    _refresh();
                                  }
                                : null,
                            title: "Add",
                          ),
                        ),
                      )
                    ],
                  ),
                  if (selectedUser != null)
                    CustomForm(
                      fields: wireframe,
                      formKey: _fbKey,
                      viewType: ViewType.newForm,
                      editMode: true,
                    ),
                  ..._generateChildren(
                    docInfo["shared"],
                  )
                ],
              );
            } else if (snapshot.hasError) {
              return handleError(snapshot.error);
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
