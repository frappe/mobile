import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/palette.dart';

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
    return CircleAvatar(
      radius: size,
      backgroundColor: Palette.bgColor,
      backgroundImage: imageProvider,
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

  Future<Widget> getAvatar(String uid) async {
    if (uid == null) {
      return Container();
    }
    var allUsers = await OfflineStorage.getItem('allUsers');
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
    return FutureBuilder(
      future: getAvatar(uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data;
        } else if (snapshot.hasError) {
          return Text(snapshot.error);
        } else {
          return Container();
        }
      },
    );
  }
}
