import 'package:flutter/material.dart';
import 'package:frappe_app/screens/module_view.dart';
import 'package:frappe_app/screens/queue.dart';
import 'package:frappe_app/screens/settings.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class CustomPersistentBottomNavBar extends StatelessWidget {
  final PersistentTabController _persistentTabController =
      PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      ModuleView(),
      QueueList(),
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
        // icon: Badge(
        //   badgeColor: Colors.white,
        //   badgeContent: Text(queue.length.toString()),
        //   child: Icon(
        //     Icons.cloud_queue,
        //   ),
        // ),
        // TODO
        activeColor: Colors.black54,
        icon: Icon(
          Icons.cloud_queue,
          color: Colors.black54,
        ),
        title: "Queue",
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
