import 'package:flutter/material.dart';

import '../config/palette.dart';

class UserAvatar extends StatelessWidget {
  final String uid;

  UserAvatar(this.uid);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Palette.bgColor,
      child: Text(uid[0].toUpperCase()),
    );
  }
}
