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

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  @override
  Widget build(BuildContext context) {
    return PersistentTabView.custom(
      context,
      itemCount: 3,
      controller: _controller,
      screens: _buildScreens(),
      customWidget: CustomNavBarWidget(
        items: _navBarsItems(),
        onItemSelected: (index) {
          setState(() {
            _controller.index = index;
          });
        },
        selectedIndex: _controller.index,
      ),
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
        inactiveIcon: FrappeIcon(
          FrappeIcons.home_outlined,
          color: FrappePalette.grey[500],
        ),
        icon: FrappeIcon(
          FrappeIcons.home_filled,
        ),
        activeColorPrimary: FrappePalette.grey[800]!,
        inactiveColorPrimary: FrappePalette.grey[500],
      ),
      PersistentBottomNavBarItem(
        title: 'Search',
        icon: FrappeIcon(
          FrappeIcons.search,
          color: FrappePalette.grey[800],
        ),
        inactiveIcon: FrappeIcon(
          FrappeIcons.search,
          color: FrappePalette.grey[500],
        ),
        activeColorPrimary: FrappePalette.grey[800]!,
        inactiveColorPrimary: FrappePalette.grey[500],
      ),
      PersistentBottomNavBarItem(
        title: 'Profile',
        icon: UserAvatar(
          uid: Config().userId!,
          size: 12,
        ),
        activeColorPrimary: FrappePalette.grey[800]!,
        inactiveColorPrimary: FrappePalette.grey[500],
      ),
    ];
  }
}

class CustomNavBarWidget extends StatelessWidget {
  final int selectedIndex;
  final List<PersistentBottomNavBarItem> items;
  final ValueChanged<int> onItemSelected;

  CustomNavBarWidget({
    required this.selectedIndex,
    required this.items,
    required this.onItemSelected,
  });

  Widget _buildItem(PersistentBottomNavBarItem item, bool isSelected) {
    return Container(
      alignment: Alignment.center,
      height: kBottomNavigationBarHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: IconTheme(
              data: IconThemeData(
                  size: 26.0,
                  color: isSelected
                      ? (item.activeColorSecondary == null
                          ? item.activeColorPrimary
                          : item.activeColorSecondary)
                      : item.inactiveColorPrimary == null
                          ? item.activeColorPrimary
                          : item.inactiveColorPrimary),
              child: isSelected ? item.icon : item.inactiveIcon ?? item.icon,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Material(
              type: MaterialType.transparency,
              child: FittedBox(
                  child: Text(
                item.title!,
                style: TextStyle(
                    color: isSelected
                        ? (item.activeColorSecondary == null
                            ? item.activeColorPrimary
                            : item.activeColorSecondary)
                        : item.inactiveColorPrimary,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.0),
              )),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Container(
        width: double.infinity,
        height: kBottomNavigationBarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            int index = items.indexOf(item);
            return TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              onPressed: () {
                this.onItemSelected(index);
              },
              child: _buildItem(item, selectedIndex == index),
            );
          }).toList(),
        ),
      ),
    );
  }
}
