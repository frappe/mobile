import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/views/awesome_bar.dart';
import 'package:frappe_app/utils/frappe_icon.dart';

import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'module_view.dart';
import 'settings.dart';

class Home extends StatelessWidget {
  final PersistentTabController _persistentTabController =
      PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      ModuleView(),
      AwesomeBar(),
      SettingsPage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        activeColor: Colors.black54,
        icon: Icon(
          Icons.home,
          color: Colors.black54,
        ),
        title: "Home",
      ),
      PersistentBottomNavBarItem(
        activeColor: Colors.black54,
        icon: FrappeIcon(
          FrappeIcons.search,
        ),
        title: "Search",
      ),
      PersistentBottomNavBarItem(
        activeColor: Colors.black54,
        icon: Icon(
          Icons.settings,
          color: Colors.black54,
        ),
        title: "Settings",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      controller: _persistentTabController,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      // decoration: NavBarDecoration(
      //     colorBehindNavBar: Colors.indigo,
      //     borderRadius: BorderRadius.circular(20.0)),
      popAllScreensOnTapOfSelectedTab: true,
      itemAnimationProperties: ItemAnimationProperties(
        duration: Duration(milliseconds: 400),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: ScreenTransitionAnimation(
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle:
          NavBarStyle.style13, // Choose the nav bar style with this property
    );
  }
}
