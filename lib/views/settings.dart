import 'package:flutter/material.dart';
import 'package:frappe_app/app/router.gr.dart';

import '../services/navigation_service.dart';
import '../config/palette.dart';
import '../app/locator.dart';
import '../utils/helpers.dart';
import '../widgets/card_list_tile.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      backgroundColor: Palette.bgColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardListTile(
            title: Text('Activate Modules'),
            onTap: () {
              locator<NavigationService>().navigateTo(
                Routes.activateModules,
              );
            },
          ),
          CardListTile(
            title: Text('Queue'),
            onTap: () {
              locator<NavigationService>().navigateTo(
                Routes.queueList,
              );
            },
          ),
          CardListTile(
            title: Text('Logout'),
            onTap: () async {
              await clearLoginInfo();
              locator<NavigationService>().clearAllAndNavigateTo(Routes.login);
            },
          ),
        ],
      ),
    );
  }
}
