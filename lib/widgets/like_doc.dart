import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/utils/backend_service.dart';
import 'package:frappe_app/utils/frappe_icon.dart';

class LikeDoc extends StatefulWidget {
  bool isFav;
  final String doctype;
  final String name;

  LikeDoc({
    @required this.isFav,
    @required this.doctype,
    @required this.name,
  });

  @override
  _LikeDocState createState() => _LikeDocState();
}

class _LikeDocState extends State<LikeDoc> {
  _toggleFav() async {
    setState(() {
      widget.isFav = !widget.isFav;
    });

    var response = await BackendService.toggleLike(
      widget.doctype,
      widget.name,
      widget.isFav,
    );

    if (response.statusCode == 200) {
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
          color: widget.isFav ? null : Palette.iconColor,
        ),
      ),
      onTap: _toggleFav,
    );
  }
}
