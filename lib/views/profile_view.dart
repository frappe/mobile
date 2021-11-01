import 'package:flutter/material.dart';
import 'package:frappe_app/app/locator.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/model/config.dart';
import 'package:frappe_app/services/api/api.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/utils/helpers.dart';
import 'package:frappe_app/utils/navigation_helper.dart';
import 'package:frappe_app/views/login/login_view.dart';
import 'package:frappe_app/views/queue.dart';
import 'package:frappe_app/widgets/frappe_bottom_sheet.dart';
import 'package:frappe_app/widgets/frappe_button.dart';
import 'package:frappe_app/widgets/padded_card_list_tile.dart';
import 'package:frappe_app/widgets/user_avatar.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:url_launcher/url_launcher.dart';

import 'form_view/form_view.dart';

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.8,
        title: Text(
          'Profile',
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            children: [
              SizedBox(
                height: 8,
              ),
              UserAvatar(
                uid: Config().userId!,
                size: 120,
                shape: ImageShape.roundedRectangle,
              ),
              SizedBox(
                height: 6,
              ),
              Text(
                Config().user,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: FrappePalette.grey[900],
                ),
              ),
              // TODO: add view profile
              // SizedBox(
              //   height: 3,
              // ),
              // Text(
              //   'View Profile',
              //   style: TextStyle(
              //     color: FrappePalette.blue,
              //     fontSize: 13,
              //   ),
              // ),
              SizedBox(
                height: 14,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[400]!,
                        blurRadius: 3.0,
                        offset: Offset(0, 1),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Column(
                    children: [
                      ProfileListTile(
                        title: "My Settings",
                        onTap: () {
                          pushNewScreen(
                            context,
                            screen: FormView(
                              name: Config().userId!,
                              doctype: "User",
                            ),
                            withNavBar: true,
                          );
                        },
                        icon: FrappeIcon(
                          FrappeIcons.my_settings,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                        ),
                        child: Divider(),
                      ),
                      ProfileListTile(
                        title: "Documentation",
                        onTap: () async {
                          var url = "https://docs.erpnext.com/homepage";
                          if (await canLaunch(url)) {
                            await launch(
                              url,
                            );
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        icon: FrappeIcon(
                          FrappeIcons.file,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                        ),
                        child: Divider(),
                      ),
                      ProfileListTile(
                        title: "User Forum",
                        onTap: () async {
                          var url = "https://discuss.erpnext.com/";
                          if (await canLaunch(url)) {
                            await launch(
                              url,
                            );
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        icon: FrappeIcon(
                          FrappeIcons.message_1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                        ),
                        child: Divider(),
                      ),
                      ProfileListTile(
                        icon: FrappeIcon(
                          FrappeIcons.bug,
                        ),
                        onTap: () async {
                          var issueUrl =
                              "https://github.com/frappe/mobile/issues";
                          if (await canLaunch(issueUrl)) {
                            await launch(
                              issueUrl,
                            );
                          } else {
                            throw 'Could not launch $issueUrl';
                          }
                        },
                        title: "Report an Issue",
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                        ),
                        child: Divider(),
                      ),
                      ProfileListTile(
                        title: "About",
                        onTap: () async {
                          var apps = await locator<Api>().getVersions();
                          showModalBottomSheet(
                            context: context,
                            useRootNavigator: true,
                            isScrollControlled: true,
                            builder: (context) {
                              var socialMediaLinks = [
                                {
                                  "title": "Website",
                                  "url": "https://frappeframework.com",
                                },
                                {
                                  "title": "Source",
                                  "url": "https://github.com/frappe",
                                },
                                {
                                  "title": "Linkedin",
                                  "url":
                                      "https://linkedin.com/company/frappe-tech",
                                },
                                {
                                  "title": "Facebook",
                                  "url": "https://facebook.com/erpnext",
                                },
                                {
                                  "title": "Twitter",
                                  "url": "https://twitter.com/erpnext",
                                }
                              ];
                              return FractionallySizedBox(
                                heightFactor: 0.8,
                                child: Container(
                                  child: FrappeBottomSheet(
                                    title: "Frappe Framework",
                                    trailing: Text("Close"),
                                    onActionButtonPress: () {
                                      Navigator.of(context).pop();
                                    },
                                    showLeading: false,
                                    body: ConstrainedFlexView(
                                      MediaQuery.of(context).size.height - 200,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Text(
                                              'Open Source Applications for the Web',
                                            ),
                                          ),
                                          ...socialMediaLinks.map(
                                            (socialMediaLink) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 8.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "${socialMediaLink["title"]!}: ",
                                                    ),
                                                    GestureDetector(
                                                      child: Text(
                                                        socialMediaLink["url"]!,
                                                        style: TextStyle(
                                                          color: FrappePalette
                                                              .blue,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ).toList(),
                                          Divider(
                                            thickness: 1,
                                          ),
                                          Text(
                                            "Installed Apps",
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          ...apps.message.frappeApps.values.map(
                                            (app) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 8.0,
                                                ),
                                                child: Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: "${app.title!}: ",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            "${app.version!} (${app.branch!})",
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ).toList(),
                                          Spacer(),
                                          Divider(
                                            thickness: 1,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8.0,
                                            ),
                                            child: Text(
                                              "© Frappe Technologies Pvt. Ltd and contributors",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        icon: FrappeIcon(
                          FrappeIcons.info_outlined,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                        ),
                        child: Divider(),
                      ),
                      ProfileListTile(
                        title: "View Website",
                        onTap: () async {
                          var url = Config().baseUrl!;
                          if (await canLaunch(url)) {
                            await launch(
                              url,
                            );
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        icon: FrappeIcon(
                          FrappeIcons.external_link,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 18,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: FrappeRaisedButton(
                  height: 48,
                  fullWidth: true,
                  onPressed: () async {
                    await clearLoginInfo();
                    NavigationHelper.clearAllAndNavigateTo(
                      context: context,
                      page: Login(),
                    );
                  },
                  icon: FrappeIcons.logout,
                  titleWidget: Text(
                    "Logout",
                    style: TextStyle(
                      color: FrappePalette.red[600],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileListTile extends StatelessWidget {
  final void Function() onTap;
  final String title;
  final Widget icon;

  const ProfileListTile({
    required this.onTap,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minLeadingWidth: 10,
      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
      leading: icon,
      trailing: FrappeIcon(
        FrappeIcons.arrow_right,
        size: 18,
        color: FrappePalette.grey[700],
      ),
      onTap: onTap,
      title: Text(title),
    );
  }
}

class ConstrainedFlexView extends StatelessWidget {
  final Widget child;
  final double minSize;
  final Axis axis;

  const ConstrainedFlexView(
    this.minSize, {
    required this.child,
    this.axis = Axis.vertical,
  });

  bool get isHz => axis == Axis.horizontal;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        double viewSize = isHz ? constraints.maxWidth : constraints.maxHeight;
        if (viewSize > minSize) return child;
        return SingleChildScrollView(
          scrollDirection: axis,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: isHz ? double.infinity : minSize,
                maxWidth: isHz ? minSize : double.infinity),
            child: child,
          ),
        );
      },
    );
  }
}
