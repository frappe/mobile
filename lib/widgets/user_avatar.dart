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

  static Widget renderShape({
    String txt,
    ImageProvider imageProvider,
    double size = 40,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(20)),
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
      var imageUrl = user != null ? user["user_image"] : null;
      if (imageUrl != null) {
        if (!Uri.parse(imageUrl).isAbsolute) {
          imageUrl = getAbsoluteUrl(imageUrl);
        }
        return CachedNetworkImage(
          imageUrl: imageUrl,
          httpHeaders: {
            HttpHeaders.cookieHeader: cookies,
          },
          imageBuilder: (context, imageProvider) => UserAvatar.renderShape(
            imageProvider: imageProvider,
            size: size,
            borderRadius: borderRadius,
          ),
          placeholder: (context, url) => UserAvatar.renderShape(
            txt: getInitials(
              user["full_name"],
            ),
            size: size,
            borderRadius: borderRadius,
          ),
          errorWidget: (context, url, error) => UserAvatar.renderShape(
            txt: '',
            size: size,
            borderRadius: borderRadius,
          ),
        );
      } else if (user == null) {
        return UserAvatar.renderShape(
          txt: uid[0].toUpperCase(),
          size: size,
          borderRadius: borderRadius,
        );
      } else {
        return UserAvatar.renderShape(
          txt: getInitials(user["full_name"]),
          size: size,
          borderRadius: borderRadius,
        );
      }
    } else {
      return UserAvatar.renderShape(
        txt: uid[0].toUpperCase(),
        size: size,
        borderRadius: borderRadius,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return getAvatar(uid);
  }
}
