import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/utils/enums.dart';

import '../model/offline_storage.dart';
import '../utils/helpers.dart';
import '../utils/http.dart';

class UserAvatar extends StatelessWidget {
  final String uid;
  final double? size;
  final ImageShape shape;

  UserAvatar({
    required this.uid,
    this.shape = ImageShape.circle,
    this.size,
  });

  Widget renderShape({
    String? txt,
    ImageProvider? imageProvider,
    double? size,
  }) {
    if (imageProvider == null) {
      var random = Random();
      var colorIdx = random.nextInt(FrappePalette.colors.length);
      var backgroundColor = FrappePalette.colors[colorIdx][100];
      var textColor = FrappePalette.colors[colorIdx][600];

      if (shape == ImageShape.circle) {
        return CircleAvatar(
          radius: size,
          backgroundColor: backgroundColor,
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
        return ClipRRect(
          borderRadius: BorderRadius.circular(
            12,
          ),
          child: Container(
            height: size,
            width: size,
            color: backgroundColor,
            child: Center(
              child: Text(
                txt!,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                ),
              ),
            ),
          ),
        );
      }
    } else {
      if (shape == ImageShape.circle) {
        return CircleAvatar(
          radius: size,
          backgroundImage: imageProvider,
        );
      } else {
        return Image(
          height: size,
          width: size,
          image: imageProvider,
        );
      }
    }
  }

  Widget getAvatar(
    String? uid,
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
            // HttpHeaders.cookieHeader: DioHelper.cookies!,
          },
          imageBuilder: (context, imageProvider) => renderShape(
            imageProvider: imageProvider,
            size: size,
          ),
          placeholder: (context, url) => renderShape(
            txt: getInitials(
              user["full_name"],
            ),
            size: size,
          ),
          errorWidget: (context, url, error) => renderShape(
            txt: '',
            size: size,
          ),
        );
      } else if (user == null) {
        return renderShape(
          txt: uid[0].toUpperCase(),
          size: size,
        );
      } else {
        return renderShape(
          txt: getInitials(user["full_name"]),
          size: size,
        );
      }
    } else {
      return renderShape(
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
