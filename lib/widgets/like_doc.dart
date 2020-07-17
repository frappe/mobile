import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/utils/http.dart';

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
    var data = {
      'doctype': widget.doctype,
      'name': widget.name,
      'add': widget.isFav ? 'Yes' : 'No'
    };

    final response = await dio.post(
      '/method/frappe.desk.like.toggle_like',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
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
        child: Icon(
          widget.isFav ? Icons.favorite : Icons.favorite_border,
          size: 18,
          color: widget.isFav ? Colors.red : Palette.secondaryTxtColor,
        ),
      ),
      onTap: _toggleFav,
    );
  }
}
