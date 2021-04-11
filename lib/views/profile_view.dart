import 'package:flutter/material.dart';
import 'package:frappe_app/utils/helpers.dart';
import 'package:frappe_app/views/login/login_view.dart';
import 'package:frappe_app/views/queue.dart';

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
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => QueueList(),
                    ),
                  );
                },
                tileColor: Colors.white,
                visualDensity: VisualDensity(
                  vertical: -4,
                ),
                title: Text('Queue'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                onTap: () async {
                  await clearLoginInfo();
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => Login(),
                    ),
                    (_) => false,
                  );
                },
                tileColor: Colors.white,
                visualDensity: VisualDensity(
                  vertical: -4,
                ),
                title: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
