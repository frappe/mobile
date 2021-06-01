import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/form/controls/link_field.dart';
import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/model/get_doc_response.dart';
import 'package:frappe_app/model/offline_storage.dart';
import 'package:frappe_app/utils/frappe_alert.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/base_view.dart';

import 'package:frappe_app/views/form_view/bottom_sheets/assignees/assignees_bottom_sheet_viewmodel.dart';
import 'package:frappe_app/widgets/frappe_bottom_sheet.dart';
import 'package:frappe_app/widgets/user_avatar.dart';

class AssigneesBottomSheetView extends StatefulWidget {
  final String doctype;
  final String name;
  final List<Assignments> assignees;

  AssigneesBottomSheetView({
    required this.doctype,
    required this.name,
    required this.assignees,
  });

  @override
  _AssigneesBottomSheetViewState createState() =>
      _AssigneesBottomSheetViewState();
}

class _AssigneesBottomSheetViewState extends State<AssigneesBottomSheetView> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseView<AssigneesBottomSheetViewModel>(
      onModelClose: (model) {
        model.selectedUsers = [];
      },
      onModelReady: (model) {
        model.assignedUsers = widget.assignees.map<String>((assignee) {
          return assignee.owner;
        }).toList();
      },
      builder: (context, model, child) => FractionallySizedBox(
        heightFactor: 0.5,
        child: FrappeBottomSheet(
          title: 'Assignees',
          onActionButtonPress: () async {
            await model.addAssignees(
              doctype: widget.doctype,
              name: widget.name,
            );

            Navigator.of(context).pop(true);
          },
          trailing: Row(
            children: [
              FrappeIcon(
                FrappeIcons.small_add,
                color: FrappePalette.blue[500],
                size: 16,
              ),
              Text(
                'Add',
                style: TextStyle(
                  color: FrappePalette.blue[500],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              FormBuilder(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: LinkField(
                    controller: _controller,
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: FrappeIcon(
                            FrappeIcons.search,
                            size: 20,
                          ),
                        )
                      ],
                    ),
                    doctypeField: DoctypeField(
                      options: 'User',
                      label: 'Search',
                      fieldname: 'user',
                    ),
                    onSuggestionSelected: (item) {
                      model.onUserSelected(item);
                      _controller.clear();
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: _generateChildren(
                    model: model,
                    context: context,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _generateChildren({
    required AssigneesBottomSheetViewModel model,
    required BuildContext context,
  }) {
    var users = <Widget>[];

    users.addAll(model.selectedUsers.asMap().entries.map<Widget>(
      (entry) {
        var user = entry.value;
        var index = entry.key;

        return UserTile(
          userId: user,
          onRemove: () {
            model.removeUser(index);
          },
        );
      },
    ).toList());

    users.addAll(model.assignedUsers.map<Widget>((user) {
      return UserTile(
        userId: user,
        onRemove: () async {
          try {
            await model.removeAssignedUser(
              doctype: widget.doctype,
              name: widget.name,
              user: user,
            );

            FrappeAlert.infoAlert(
              context: context,
              title: "$user has been removed",
            );
          } catch (e) {
            print(e);
          }
        },
      );
    }).toList());

    return users;
  }
}

class UserTile extends StatelessWidget {
  final String userId;
  final void Function()? onRemove;

  const UserTile({
    required this.userId,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    var allUsers = OfflineStorage.getItem('allUsers');
    allUsers = allUsers["data"];
    if (allUsers != null) {
      var user = allUsers[userId];

      return ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 5,
        ),
        leading: UserAvatar(
          uid: userId,
        ),
        trailing: IconButton(
          icon: FrappeIcon(
            FrappeIcons.close_alt,
            size: 20,
          ),
          onPressed: onRemove,
        ),
        title: Text(
          user["full_name"],
          style: TextStyle(
            color: FrappePalette.grey[900],
          ),
        ),
      );
    } else {
      return ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 5,
        ),
        leading: UserAvatar(
          uid: userId,
        ),
        trailing: IconButton(
          icon: FrappeIcon(
            FrappeIcons.close_alt,
            size: 20,
          ),
          onPressed: onRemove,
        ),
        title: Text(
          userId,
          style: TextStyle(
            color: FrappePalette.grey[900],
          ),
        ),
      );
    }
  }
}
