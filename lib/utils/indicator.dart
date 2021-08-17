// @dart=2.9

import 'package:flutter/material.dart';
import 'package:frappe_app/config/palette.dart';

class Indicator {
  static Widget buildStatusButton(String doctype, String status) {
    var doctypeColor = {
      'Issue': {
        'Open': indicateDanger(status),
        'Closed': indicateSuccess(status),
      }
    };

    if (doctypeColor[doctype] != null &&
        doctypeColor[doctype][status] != null) {
      return doctypeColor[doctype][status];
    } else if (["Pending", "Review", "Medium", "Not Approved"]
        .contains(status)) {
      return indicateWarning(status);
    } else if (["Open", "Urgent", "High", "Failed", "Rejected", "Error"]
        .contains(status)) {
      return indicateDanger(status);
    } else if ([
      "Closed",
      "Finished",
      "Converted",
      "Completed",
      "Complete",
      "Confirmed",
      "Approved",
      "Yes",
      "Active",
      "Available",
      "Paid",
      "Success",
    ].contains(status)) {
      return indicateSuccess(status);
    } else if (["Submitted", "Enabled"].contains(status)) {
      return indicateComplete(status);
    } else {
      return indicateUndefined(status);
    }
  }

  static Widget buildIndicator(String title, Map<String, Color> color) {
    return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 60,
        ),
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color['bgColor'],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text(
              title ?? "",
              style: TextStyle(
                color: color['txtColor'],
                fontSize: 12,
              ),
            ),
          ),
        ));
  }

  static Widget indicateDanger(String title) {
    return buildIndicator(
      title,
      {
        'txtColor': Palette.dangerTxtColor,
        'bgColor': Palette.dangerBgColor,
      },
    );
  }

  static Widget indicateSuccess(String title) {
    return buildIndicator(
      title,
      {
        'txtColor': Palette.successTxtColor,
        'bgColor': Palette.successBgColor,
      },
    );
  }

  static Widget indicateWarning(String title) {
    return buildIndicator(
      title,
      {
        'txtColor': Palette.warningTxtColor,
        'bgColor': Palette.warningBgColor,
      },
    );
  }

  static Widget indicateComplete(String title) {
    return buildIndicator(
      title,
      {
        'txtColor': Palette.completeTxtColor,
        'bgColor': Palette.completeBgColor,
      },
    );
  }

  static Widget indicateUndefined(String title) {
    return buildIndicator(
      title,
      {
        'txtColor': Palette.undefinedTxtColor,
        'bgColor': Palette.undefinedBgColor,
      },
    );
  }
}
