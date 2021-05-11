import 'package:flutter/material.dart';

import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/model/get_doc_response.dart';

import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/base_view.dart';
import 'package:frappe_app/views/form_view/bottom_sheets/reviews/add_review_bottom_sheet_view.dart';
import 'package:frappe_app/views/form_view/bottom_sheets/reviews/view_reviews_bottom_sheet_viewmodel.dart';

import 'package:frappe_app/widgets/frappe_bottom_sheet.dart';
import 'package:frappe_app/widgets/review_pill.dart';

class ViewReviewsBottomSheetView extends StatelessWidget {
  final List reviews;

  final String name;
  final DoctypeDoc meta;
  final Map doc;
  final Docinfo docinfo;

  const ViewReviewsBottomSheetView({
    required this.reviews,
    required this.name,
    required this.meta,
    required this.doc,
    required this.docinfo,
  });

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
          onActionButtonPress: () {
            Navigator.of(context).pop();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => AddReviewBottomSheetView(
                name: name,
                meta: meta,
                doc: doc,
                docinfo: docinfo,
              ),
            );
          },
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
                reviews[index],
              );
            },
          ),
        ),
      ),
    );
  }
}
