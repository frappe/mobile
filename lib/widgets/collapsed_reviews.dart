import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/widgets/review_pill.dart';

class CollapsedReviews extends StatelessWidget {
  final List data;

  const CollapsedReviews(
    this.data,
  );

  List<Widget> _genearateChildren() {
    var displayedReviews = [];
    var maxSize = 2;
    var remaining = data.length - maxSize;
    var loopSize = data.length > 2 ? 2 : data.length;

    for (var i = 0; i <= loopSize - 1; i++) {
      displayedReviews.add(data[i]);
    }
    var widgets = displayedReviews.map<Widget>(
      (item) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ReviewPill(
            review: item,
          ),
        );
      },
    ).toList();

    if (remaining > 0) {
      widgets.add(
        CircleAvatar(
          backgroundColor: FrappePalette.grey[50],
          radius: 20,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: FrappePalette.orange[100],
            child: Text(
              '+$remaining',
              style: TextStyle(
                fontSize: 12,
                color: FrappePalette.orange[600],
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 203,
      child: Row(
        children: _genearateChildren(),
      ),
    );
  }
}
