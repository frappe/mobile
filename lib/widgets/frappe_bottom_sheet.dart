import 'package:flutter/material.dart';
import 'package:frappe_app/app/locator.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/services/navigation_service.dart';

class FrappeBottomSheet extends StatelessWidget {
  final Widget body;

  final String title;
  final Widget trailing;
  final Function onActionButtonPress;

  const FrappeBottomSheet({
    Key key,
    this.body,
    @required this.title,
    this.trailing,
    this.onActionButtonPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFF737373),
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 13,
                  color: FrappePalette.blue[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              padding: EdgeInsets.zero,
              minWidth: 70,
              onPressed: () {
                locator<NavigationService>().pop();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: FrappePalette.grey[900],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FlatButton(
              padding: EdgeInsets.zero,
              minWidth: 65,
              child: trailing,
              onPressed: onActionButtonPress,
            )
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 18,
        ),
        child: body,
      ),
    );
  }
}
