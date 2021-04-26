import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/widgets/user_avatar.dart';
import 'package:overflow_view/overflow_view.dart';

class CollapsedAvatars extends StatelessWidget {
  final List data;

  const CollapsedAvatars(
    this.data,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: data.length > 3 ? 106 : null,
      child: OverflowView(
        spacing: -18,
        children: data.map<Widget>(
          (item) {
            return CircleAvatar(
              backgroundColor: FrappePalette.grey[50],
              radius: 20,
              child: UserAvatar(
                size: 18,
                uid: item,
              ),
            );
          },
        ).toList(),
        builder: (context, remaining) {
          return CircleAvatar(
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
          );
        },
      ),
    );
  }
}
