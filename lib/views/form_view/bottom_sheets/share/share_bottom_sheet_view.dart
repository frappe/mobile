// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/app/locator.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/form/controls/multi_select.dart';
import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/model/get_doc_response.dart';
import 'package:frappe_app/model/offline_storage.dart';
import 'package:frappe_app/services/api/api.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/base_view.dart';

import 'package:frappe_app/views/form_view/bottom_sheets/share/share_bottom_sheet_viewmodel.dart';
import 'package:frappe_app/widgets/frappe_bottom_sheet.dart';
import 'package:frappe_app/widgets/user_avatar.dart';

class ShareBottomSheetView extends StatelessWidget {
  final String doctype;
  final String name;
  final List<Shared> shares;

  const ShareBottomSheetView({
    Key key,
    @required this.doctype,
    @required this.name,
    @required this.shares,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<ShareBottomSheetViewModel>(
      onModelClose: (model) {
        model.shareWithUsers = [];
      },
      onModelReady: (model) {
        model.currentShares = shares;
      },
      builder: (context, model, child) => FractionallySizedBox(
        heightFactor: 0.9,
        child: FrappeBottomSheet(
          title: 'Shared With',
          bottomBar: model.shareWithUsers.isEmpty
              ? null
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: FrappePalette.grey[200],
                      ),
                    ),
                  ),
                  height: 50,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: FrappeIcon(FrappeIcons.lock),
                      ),
                      Text(
                        'Choose permission level',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: PopupMenuButton(
                          onSelected: (permission) {
                            model.selectPermission(permission);
                          },
                          child: Row(
                            children: [
                              Text(
                                model.currentPermission,
                                style: TextStyle(
                                  color: FrappePalette.blue,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              FrappeIcon(
                                FrappeIcons.down_arrow,
                                size: 16,
                                color: FrappePalette.blue,
                              )
                            ],
                          ),
                          itemBuilder: (context) {
                            return model.permissionLevels.map(
                              (permissionLevel) {
                                return PopupMenuItem(
                                  child: Text(permissionLevel),
                                  value: permissionLevel,
                                );
                              },
                            ).toList();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          onActionButtonPress: () {
            model.addShare(
              doctype: doctype,
              users: model.shareWithUsers,
              name: name,
              permission: model.currentPermission,
            );
          },
          trailing: model.shareWithUsers.isEmpty
              ? null
              : Row(
                  children: [
                    Text(
                      'Share',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ),
                  child: MultiSelect(
                    onChanged: (l) {
                      model.updateNewShares(l);
                    },
                    findSuggestions: (String query) async {
                      if (query.length != 0) {
                        var lowercaseQuery = query.toLowerCase();
                        var response = await locator<Api>().searchLink(
                          doctype: 'User',
                          txt: lowercaseQuery,
                        );

                        return response["results"];
                      } else {
                        return [];
                      }
                    },
                    doctypeField: DoctypeField(
                      label: 'Add people or emails',
                      fieldname: 'users',
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
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
    @required ShareBottomSheetViewModel model,
    BuildContext context,
  }) {
    var allUsers = OfflineStorage.getItem('allUsers');
    allUsers = allUsers["data"];
    if (allUsers != null) {
      return model.currentShares.map((share) {
        var user = allUsers[share.user];
        return SharedWithUser(
          share: share,
          user: user,
          model: model,
          doctype: doctype,
          name: name,
        );
      }).toList();
    } else {
      return [Container()];
    }
  }
}

class SharedWithUser extends StatelessWidget {
  final Map user;
  final Shared share;
  final ShareBottomSheetViewModel model;
  final String doctype;
  final String name;

  const SharedWithUser({
    Key key,
    this.user,
    this.share,
    this.model,
    this.doctype,
    this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title;
    String subtitle;
    String userPermission;

    if (user != null) {
      title = user["full_name"];
    } else if (share.user == null && share.everyone == 1) {
      title = "Everyone";
    } else {
      title = share.user;
    }

    if (user != null) {
      subtitle = share.user;
    }

    if (share.read == 1 && share.write == 1 && share.share == 1) {
      userPermission = "Full Access";
    } else if (share.write == 1) {
      userPermission = "Can Write";
    } else if (share.share == 1) {
      userPermission = "Can Share";
    } else if (share.read == 1) {
      userPermission = "Can Read";
    }
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 5,
      ),
      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
      leading: UserAvatar(
        uid: share.user ?? "E",
      ),
      title: Text(
        title,
      ),
      subtitle: Text(
        subtitle ?? "",
      ),
      trailing: PopupMenuButton(
        onSelected: (permission) {
          model.updatePermission(
            currentPermission: userPermission,
            newPermission: permission,
            doctype: doctype,
            name: name,
            user: share.user,
          );
        },
        child: Container(
          height: 50,
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                userPermission,
                style: TextStyle(
                  color: FrappePalette.grey[600],
                ),
              ),
              SizedBox(
                width: 5,
              ),
              FrappeIcon(
                FrappeIcons.down_arrow,
                size: 16,
                color: FrappePalette.grey[600],
              )
            ],
          ),
        ),
        itemBuilder: (context) {
          return model.permissionLevels.map(
            (permissionLevel) {
              return PopupMenuItem(
                child: Text(permissionLevel),
                value: permissionLevel,
              );
            },
          ).toList();
        },
      ),
    );
  }
}
