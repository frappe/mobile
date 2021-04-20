// @dart=2.9

import 'package:flutter/material.dart';

import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';

import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/base_view.dart';
import 'package:frappe_app/views/form_view/bottom_sheets/reviews/view_reviews_bottom_sheet_viewmodel.dart';

import 'package:frappe_app/widgets/frappe_bottom_sheet.dart';
import 'package:frappe_app/widgets/review_pill.dart';

class ViewReviewsBottomSheetView extends StatelessWidget {
  final List reviews;

  const ViewReviewsBottomSheetView({
    Key key,
    @required this.reviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 4 - 60;
    final double itemWidth = size.width / 2;

    return BaseView<ViewReviewsBottomSheetViewModel>(
      onModelClose: (model) {},
      builder: (context, model, child) => FractionallySizedBox(
        heightFactor: 0.3,
        child: FrappeBottomSheet(
          title: 'Reviews',
          onActionButtonPress: () {},
          trailing: Row(
            children: [
              FrappeIcon(
                FrappeIcons.small_add,
                color: FrappePalette.blue[500],
                size: 16,
              ),
              Text(
                'Add',
                style: TextStyle(
                  color: FrappePalette.blue[500],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          body: GridView.builder(
            itemCount: reviews.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: (itemWidth / itemHeight),
            ),
            itemBuilder: (context, index) {
              return ReviewPill(
                review: reviews[index],
              );
            },
          ),
        ),
      ),
    );
  }
}
