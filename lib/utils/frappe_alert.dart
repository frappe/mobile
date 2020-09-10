import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/utils/frappe_icon.dart';

class FrappeAlert {
  static showAlert({
    @required String icon,
    @required String title,
    String subtitle,
    @required BuildContext context,
    @required MaterialColor color,
    Duration aleartDuration = const Duration(seconds: 5),
  }) {
    FToast fToast = FToast(context);

    var toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        color: color[100],
      ),
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FrappeIcon(
            icon,
            color: color,
          ),
          SizedBox(
            width: 12.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                SizedBox(
                  height: 4.0,
                ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color[600],
                  ),
                ),
            ],
          )
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: aleartDuration,
    );
  }

  static infoAlert({
    String title,
    String subtitle,
    BuildContext context,
  }) {
    FrappeAlert.showAlert(
      icon: FrappeIcons.info,
      title: title,
      context: context,
      color: FrappePalette.blue,
      subtitle: subtitle,
    );
  }

  static warnAlert({
    String title,
    String subtitle,
    BuildContext context,
  }) {
    FrappeAlert.showAlert(
      icon: FrappeIcons.warning,
      title: title,
      context: context,
      color: FrappePalette.yellow,
      subtitle: subtitle,
    );
  }

  static errorAlert({
    String title,
    String subtitle,
    BuildContext context,
  }) {
    FrappeAlert.showAlert(
      icon: FrappeIcons.error,
      title: title,
      context: context,
      color: FrappePalette.red,
      subtitle: subtitle,
    );
  }

  static successAlert({
    String title,
    String subtitle,
    BuildContext context,
  }) {
    FrappeAlert.showAlert(
      icon: FrappeIcons.success,
      title: title,
      context: context,
      color: FrappePalette.darkGreen,
      subtitle: subtitle,
    );
  }
}
