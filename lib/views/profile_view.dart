import 'package:flutter/material.dart';
import 'package:frappe_app/utils/helpers.dart';
import 'package:frappe_app/utils/navigation_helper.dart';
import 'package:frappe_app/views/login/login_view.dart';
import 'package:frappe_app/views/queue.dart';
import 'package:frappe_app/widgets/card_list_tile.dart';

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.8,
        title: Text(
          'Profile',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Column(
          children: [
            CardListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => QueueList(),
                  ),
                );
              },
              title: Text("Queue"),
            ),
            CardListTile(
              onTap: () async {
                await clearLoginInfo();
                NavigationHelper.clearAllAndNavigateTo(
                  context: context,
                  page: Login(),
                );
              },
              title: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
