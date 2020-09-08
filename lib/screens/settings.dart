import 'package:flutter/material.dart';

import '../config/palette.dart';
import '../screens/activate_modules.dart';
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
            title: Text('Logout'),
            onTap: () {
              logout(context);
            },
          ),
        ],
      ),
    );
  }
}
