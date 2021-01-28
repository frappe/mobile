import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../views/add_assignees/add_assignees_viewmodel.dart';
import '../../views/base_view.dart';

import '../../datamodels/doctype_response.dart';
import '../../app/locator.dart';
import '../../config/palette.dart';
import '../../form/controls/link_field.dart';
import '../../utils/enums.dart';

import '../../services/api/api.dart';
import '../../services/navigation_service.dart';

import '../../widgets/card_list_tile.dart';
import '../../widgets/frappe_button.dart';
import '../../widgets/user_avatar.dart';

class AddAssignees extends StatelessWidget {
  final String doctype;
  final String name;

  AddAssignees({
    Key key,
    @required this.doctype,
    @required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<AddAssigneesViewModel>(
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
                      onPressed: model.newAssignees.length > 0
                          ? () async {
                              await locator<Api>().addAssignees(
                                doctype,
                                name,
                                model.newAssignees,
                              );
                              locator<NavigationService>().pop(true);
                            }
                          : null,
                      title: "Assign",
                      buttonType: ButtonType.primary,
                    ),
                  )
                ],
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: FormBuilder(
                      child: LinkField(
                        withLabel: false,
                        key: UniqueKey(),
                        prefixIcon: Icon(Icons.search),
                        fillColor: Colors.white,
                        doctypeField: DoctypeField(
                          options: 'User',
                          label: 'Assign To',
                        ),
                        onSuggestionSelected: (item) {
                          model.selectUser(item["value"]);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: _generateChildren(model),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  List<Widget> _generateChildren(AddAssigneesViewModel model) {
    List<Widget> children = [];
    if (model.newAssignees.isNotEmpty) {
      children = model.newAssignees.asMap().entries.map<Widget>((entry) {
        var idx = entry.key;
        var val = entry.value;
        return CardListTile(
          color: Palette.newIndicatorColor,
          leading: UserAvatar(
            uid: val,
          ),
          title: Text(val),
          trailing: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              model.newAssignees.removeAt(idx);
            },
          ),
        );
      }).toList();
    }

    return children;
  }
}
