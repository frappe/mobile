import 'package:flutter/material.dart';

import '../services/navigation_service.dart';
import '../config/palette.dart';
import '../screens/queue.dart';
import '../screens/activate_modules.dart';
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ActivateModules();
                  },
                ),
              );
            },
          ),
          CardListTile(
            title: Text('Queue'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return QueueList();
                  },
                ),
              );
            },
          ),
          CardListTile(
            title: Text('Logout'),
            onTap: () async {
              await clearLoginInfo();
              locator<NavigationService>().clearAllAndNavigateTo('login');
            },
          ),
        ],
      ),
    );
  }
}
