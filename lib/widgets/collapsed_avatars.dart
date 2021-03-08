import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/widgets/user_avatar.dart';
import 'package:overflow_view/overflow_view.dart';

class CollapsedAvatars extends StatelessWidget {
  final List data;

  const CollapsedAvatars(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: data.length > 3 ? 120 : null,
      child: OverflowView(
        spacing: -16,
        children: data.map<Widget>(
          (item) {
            return CircleAvatar(
              backgroundColor: FrappePalette.grey[50],
              radius: 22,
              child: UserAvatar(
                uid: item["owner"],
              ),
            );
          },
        ).toList(),
        builder: (context, remaining) {
          return CircleAvatar(
            backgroundColor: FrappePalette.grey[50],
            radius: 22,
            child: UserAvatar(
              uid: '+$remaining',
            ),
          );
        },
      ),
    );
  }
}
