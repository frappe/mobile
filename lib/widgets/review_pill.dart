import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/model/get_doc_response.dart';
import 'package:frappe_app/widgets/user_avatar.dart';

class ReviewPill extends StatelessWidget {
  final EnergyPointLogs review;

  const ReviewPill(this.review);

  @override
  Widget build(BuildContext context) {
    var reviewType = review.type;
    var points;
    var tooltipMsg;
    if (reviewType == "Appreciation") {
      points = "+${review.points}";
      tooltipMsg =
          "${review.points} appreciation points for ${review.user} for ${review.reason}";
    } else {
      points = "${review.points}";
      tooltipMsg =
          "${review.points} criticism points for ${review.user} for ${review.reason}";
    }

    return Tooltip(
      message: tooltipMsg,
      child: Chip(
        labelPadding: EdgeInsets.symmetric(horizontal: 2),
        avatar: UserAvatar(
          uid: review.owner,
          size: 100,
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: FrappePalette.grey[300]!,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        backgroundColor: Colors.transparent,
        label: Container(
          width: 35,
          child: Text(
            points,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: reviewType == "Appreciation"
                  ? FrappePalette.darkGreen[600]
                  : FrappePalette.red[600],
            ),
          ),
        ),
      ),
    );
  }
}
