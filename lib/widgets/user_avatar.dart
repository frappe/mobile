import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_palette.dart';

import '../model/offline_storage.dart';
import '../utils/dio_helper.dart';
import '../utils/helpers.dart';
import '../utils/http.dart';

class UserAvatar extends StatelessWidget {
  final String uid;
  final double size;

  UserAvatar({
    this.uid,
    this.size,
  });

  static Widget renderShape({
    String txt,
    ImageProvider imageProvider,
    double size,
  }) {
    if (imageProvider == null) {
      var random = Random();
      var colorIdx = random.nextInt(FrappePalette.colors.length);
      var backgroundColor = FrappePalette.colors[colorIdx][100];
      var textColor = FrappePalette.colors[colorIdx][600];
      return CircleAvatar(
        radius: size,
        backgroundColor: backgroundColor,
        backgroundImage: imageProvider,
        child: txt != null
            ? Center(
                child: Text(
                  txt,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor,
                  ),
                ),
              )
            : null,
      );
    } else {
      return CircleAvatar(
        radius: size,
        backgroundImage: imageProvider,
      );
    }
  }

  Widget getAvatar(
    String uid,
  ) {
    if (uid == null) {
      return Container();
    }
    var allUsers = OfflineStorage.getItem('allUsers');
    allUsers = allUsers["data"];
    if (allUsers != null) {
      var user = allUsers[uid];
      var imageUrl = user != null ? user["user_image"] : null;
      if (imageUrl != null) {
        if (!Uri.parse(imageUrl).isAbsolute) {
          imageUrl = getAbsoluteUrl(imageUrl);
        }
        return CachedNetworkImage(
          imageUrl: imageUrl,
          httpHeaders: {
            HttpHeaders.cookieHeader: DioHelper.cookies,
          },
          imageBuilder: (context, imageProvider) => UserAvatar.renderShape(
            imageProvider: imageProvider,
            size: size,
          ),
          placeholder: (context, url) => UserAvatar.renderShape(
            txt: getInitials(
              user["full_name"],
            ),
            size: size,
          ),
          errorWidget: (context, url, error) => UserAvatar.renderShape(
            txt: '',
            size: size,
          ),
        );
      } else if (user == null) {
        return UserAvatar.renderShape(
          txt: uid[0].toUpperCase(),
          size: size,
        );
      } else {
        return UserAvatar.renderShape(
          txt: getInitials(user["full_name"]),
          size: size,
        );
      }
    } else {
      return UserAvatar.renderShape(
        txt: uid[0].toUpperCase(),
        size: size,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return getAvatar(uid);
  }
}
