// @dart=2.9
import 'package:flutter/material.dart';
import 'package:frappe_app/views/queue.dart';

import '../config/palette.dart';
import '../utils/helpers.dart';
import '../widgets/card_list_tile.dart';
import 'login/login_view.dart';

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
            title: Text('Queue'),
            onTap: () {
              Navigator.of(context).push(
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
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) {
                  return Login();
                }),
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
