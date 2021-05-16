import 'package:flutter/material.dart';

import '../app/locator.dart';
import '../config/frappe_icons.dart';
import '../config/palette.dart';
import '../services/api/api.dart';
import '../utils/frappe_icon.dart';

// ignore: must_be_immutable
class LikeDoc extends StatefulWidget {
  bool isFav;
  final String doctype;
  final String name;
  final Color? iconColor;
  final Function? successCallback;

  LikeDoc({
    required this.isFav,
    required this.doctype,
    required this.name,
    this.successCallback,
    this.iconColor,
  });

  @override
  _LikeDocState createState() => _LikeDocState();
}

class _LikeDocState extends State<LikeDoc> {
  _toggleFav() async {
    setState(() {
      widget.isFav = !widget.isFav;
    });

    var response = await locator<Api>().toggleLike(
      widget.doctype,
      widget.name,
      widget.isFav,
    );

    if (response.statusCode == 200) {
      if (widget.successCallback != null) {
        widget.successCallback!();
      }
      return;
    } else {
      setState(() {
        widget.isFav = !widget.isFav;
      });
      throw Exception('Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        child: FrappeIcon(
          widget.isFav
              ? FrappeIcons.favourite_active
              : FrappeIcons.favourite_resting,
          size: 18,
          color: widget.iconColor ?? Palette.iconColor,
        ),
      ),
      onTap: _toggleFav,
    );
  }
}
