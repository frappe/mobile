import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../config/palette.dart';
import '../utils/helpers.dart';
import '../utils/http.dart';

class UserAvatar extends StatelessWidget {
  final String uid;
  final double size;
  final BorderRadius borderRadius;

  UserAvatar({
    this.uid,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.size = 40,
  });

  Widget _renderShape({
    String txt,
    ImageProvider imageProvider,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Palette.bgColor,
        borderRadius: borderRadius,
        image: imageProvider != null
            ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
            : null,
      ),
      child: txt != null
          ? Center(
              child: Text(
                txt,
                style: TextStyle(fontSize: 12),
              ),
            )
          : null,
    );
  }

  Widget getAvatar(String uid) {
    if (uid == null) {
      return Container();
    }
    if (localStorage.containsKey('${baseUrl}allUsers')) {
      var allUsers = json.decode(localStorage.getString('${baseUrl}allUsers'));
      var user = allUsers[uid];
      var imageUrl = user != null ? user[2] : null;
      if (imageUrl != null) {
        if (!Uri.parse(imageUrl).isAbsolute) {
          imageUrl = getAbsoluteUrl(imageUrl);
        }
        return CachedNetworkImage(
          imageUrl: imageUrl,
          httpHeaders: {
            HttpHeaders.cookieHeader: cookies,
          },
          imageBuilder: (context, imageProvider) =>
              _renderShape(imageProvider: imageProvider),
          placeholder: (context, url) => _renderShape(
            txt: getInitials(
              user[1],
            ),
          ),
          errorWidget: (context, url, error) => _renderShape(txt: ''),
        );
      } else if (user == null) {
        return _renderShape(txt: uid[0].toUpperCase());
      } else {
        return _renderShape(txt: getInitials(user[1]));
      }
    } else {
      return _renderShape(txt: uid[0].toUpperCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    return getAvatar(uid);
  }
}
