import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FrappeIcon extends StatelessWidget {
  final String path;
  final Color? color;
  final double? size;

  const FrappeIcon(
    this.path, {
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      color: color,
      height: size,
      width: size,
    );
  }
}
