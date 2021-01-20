import 'package:flutter/material.dart';

import '../config/frappe_icons.dart';

import '../app/locator.dart';
import '../app/router.gr.dart';

import '../services/navigation_service.dart';

import '../utils/frappe_icon.dart';
import '../utils/config_helper.dart';
import '../utils/helpers.dart';

import '../views/awesome_bar.dart';
import '../widgets/user_avatar.dart';

class HeaderAppBar extends StatelessWidget {
  final Widget body;
  final String subtitle;
  final List<Widget> subActions;
  final bool isRoot;
  final bool showSecondaryLeading;

  const HeaderAppBar({
    Key key,
    @required this.body,
    this.isRoot = false,
    this.subtitle,
    this.subActions,
    this.showSecondaryLeading = false,
  }) : super(key: key);

  void _choiceAction(
    String choice,
  ) async {
    if (choice == 'activate_modules') {
      locator<NavigationService>().navigateTo(
        Routes.activateModules,
      );
    } else if (choice == 'queue') {
      locator<NavigationService>().navigateTo(
        Routes.queueList,
      );
    } else if (choice == 'logout') {
      await clearLoginInfo();
      locator<NavigationService>().clearAllAndNavigateTo(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            leading: isRoot
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FrappeIcon(
                        FrappeIcons.frappe,
                        size: 36,
                      ),
                    ],
                  )
                : locator<NavigationService>().canPop()
                    ? IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          locator<NavigationService>().pop();
                        },
                      )
                    : null,
            actions: [
              Spacer(
                flex: 1,
              ),
              Flexible(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Awesombar(),
                ),
              ),
              Spacer(
                flex: 1,
              ),
              Flexible(
                flex: 2,
                child: PopupMenuButton(
                  onSelected: (choice) {
                    _choiceAction(choice);
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Text('Activate Modules'),
                        value: "activate_modules",
                      ),
                      PopupMenuItem(
                        child: Text('Queue'),
                        value: "queue",
                      ),
                      PopupMenuItem(
                        child: Text('Logout'),
                        value: "logout",
                      ),
                    ];
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 10.0,
                      top: 5.0,
                    ),
                    child: UserAvatar(
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                      size: 50,
                      uid: ConfigHelper().userId,
                    ),
                  ),
                ),
              ),
            ],
            pinned: true,
            elevation: 0,
          ),
          SliverAppBar(
            primary: false,
            centerTitle: false,
            title: Text(subtitle),
            titleSpacing:
                showSecondaryLeading ? 0 : NavigationToolbar.kMiddleSpacing,
            floating: true,
            automaticallyImplyLeading: showSecondaryLeading,
            actions: subActions,
          ),
        ];
      },
      body: body,
    );
  }
}
