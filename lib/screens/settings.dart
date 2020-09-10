import 'package:flutter/material.dart';
import 'package:frappe_app/main.dart';

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container(
          //   child: Text(localStorage.getString('user')),
          //   color: Palette.bgColor,
          // ),
          // Container(
          //   child: Text(localStorage.getString('serverURL')),
          //   color: Palette.bgColor,
          // ),
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
