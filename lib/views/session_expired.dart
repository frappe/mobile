// @dart=2.9
import 'package:flutter/material.dart';
import 'package:frappe_app/views/login/login_view.dart';

import '../utils/enums.dart';
import '../widgets/frappe_button.dart';

class SessionExpired extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            'Your Session has been expired',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            'please login to continue',
            style: TextStyle(fontSize: 20),
          ),
          FrappeFlatButton(
            buttonType: ButtonType.primary,
            title: 'Login',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) {
                  return Login();
                }),
                (_) => false,
              );
            },
          )
        ]),
      ),
    );
  }
}
