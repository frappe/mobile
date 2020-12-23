import 'package:flutter/material.dart';

import '../app/locator.dart';
import '../app/router.gr.dart';

import '../services/navigation_service.dart';

import '../utils/config_helper.dart';
import '../utils/helpers.dart';

import '../views/awesome_bar.dart';
import '../widgets/user_avatar.dart';

class HeaderAppBar extends StatelessWidget {
  final Widget body;
  final Function drawerCallback;
  final String subtitle;

  const HeaderAppBar({
    Key key,
    @required this.body,
    this.drawerCallback,
    this.subtitle,
  }) : super(key: key);

  void _choiceAction(
    BuildContext context,
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
            actions: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Awesombar(),
                ),
              ),
              PopupMenuButton(
                onSelected: (choice) {
                  _choiceAction(context, choice);
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
                child: UserAvatar(
                  uid: ConfigHelper().userId,
                ),
              ),
            ],
            floating: true,
            pinned: true,
            elevation: 0,
          ),
          SliverPersistentHeader(
            floating: true,
            delegate: _SliverAppBarDelegate(
              body: Row(children: [
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: drawerCallback,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Text(subtitle),
                  ),
                ),
              ]),
              bodyMaxExtent: 20.0,
              bodyMinExtent: 0.0,
            ),
          )
        ];
      },
      body: body,
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    this.body,
    this.bodyMinExtent,
    this.bodyMaxExtent,
  });

  final Widget body;
  final double bodyMinExtent;
  final double bodyMaxExtent;

  @override
  double get minExtent => bodyMinExtent;
  @override
  double get maxExtent => bodyMaxExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return body;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
