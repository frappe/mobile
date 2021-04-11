import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/model/config.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/awesome_bar.dart';
import 'package:frappe_app/views/desk/desk_view.dart';
import 'package:frappe_app/views/profile_view.dart';
import 'package:frappe_app/widgets/user_avatar.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      screens: _buildScreens(),
      items: _navBarsItems(),
      navBarStyle: NavBarStyle.style12,
    );
  }

  List<Widget> _buildScreens() {
    return [
      DeskView(),
      Awesombar(),
      ProfileView(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        title: 'Home',
        inactiveIcon: FrappeIcon(FrappeIcons.home_outlined),
        icon: FrappeIcon(FrappeIcons.home_filled),
        activeColorPrimary: FrappePalette.grey[800],
        inactiveColorPrimary: FrappePalette.grey[800],
      ),
      PersistentBottomNavBarItem(
        title: 'Search',
        icon: FrappeIcon(FrappeIcons.search),
        activeColorPrimary: FrappePalette.grey[800],
        inactiveColorPrimary: FrappePalette.grey[800],
      ),
      PersistentBottomNavBarItem(
        title: 'Profile',
        icon: UserAvatar(
          uid: Config().userId,
        ),
        activeColorPrimary: FrappePalette.grey[800],
        inactiveColorPrimary: FrappePalette.grey[800],
      ),
    ];
  }
}
