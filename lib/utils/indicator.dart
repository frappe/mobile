import 'package:flutter/material.dart';

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
    } else if (["Submitted"].contains(status)) {
      return indicateComplete(status);
    } else {
      return indicateUndefined(status);
    }
  }

  static Widget buildIndicator(String title, Map<String, Color> color) {
    return Container(
      width: 60,
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
    );
  }

  static Widget indicateDanger(String title) {
    return buildIndicator(
      title,
      {
        'txtColor': Colors.red[800],
        'bgColor': Colors.red[50],
      },
    );
  }

  static Widget indicateSuccess(String title) {
    return buildIndicator(
      title,
      {
        'txtColor': Colors.green[800],
        'bgColor': Colors.green[50],
      },
    );
  }

  static Widget indicateWarning(String title) {
    return buildIndicator(
      title,
      {
        'txtColor': Colors.orange[800],
        'bgColor': Colors.orange[50],
      },
    );
  }

  static Widget indicateComplete(String title) {
    return buildIndicator(
      title,
      {
        'txtColor': Colors.blue[800],
        'bgColor': Colors.blue[50],
      },
    );
  }

  static Widget indicateUndefined(String title) {
    return buildIndicator(
      title,
      {
        'txtColor': Colors.grey[800],
        'bgColor': Colors.grey[50],
      },
    );
  }
}
