import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/model/get_doc_response.dart';
import 'package:frappe_app/utils/dio_helper.dart';
import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/views/login/login_view.dart';

import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../config/palette.dart';

import '../model/config.dart';

import '../widgets/user_avatar.dart';
import 'package:photo_view/photo_view.dart';

class EmailBox extends StatefulWidget {
  final Communication data;
  final Function onReplyTo;
  final Function onReplyAll;

  EmailBox({
    required this.data,
    required this.onReplyAll,
    required this.onReplyTo,
  });

  @override
  _EmailBoxState createState() => _EmailBoxState();
}

class _EmailBoxState extends State<EmailBox> {
  late bool _isExpanded;

  @override
  void initState() {
    _isExpanded = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var time = timeago.format(DateTime.parse(widget.data.creation));

    return GestureDetector(
      onTap: () {
        setState(
          () {
            _isExpanded = !_isExpanded;
          },
        );
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: _isExpanded ? double.infinity : 184,
        ),
        child: Card(
          color: Colors.white,
          child: Column(
            children: [
              ListTile(
                leading: UserAvatar(
                  uid: widget.data.sender,
                ),
                title: Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.data.senderFullName,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    if (widget.data.deliveryStatus != "")
                      widget.data.deliveryStatus == "Sent"
                          ? FrappeIcon(
                              FrappeIcons.unread_status,
                            )
                          : FrappeIcon(
                              FrappeIcons.read_status,
                              color: FrappePalette.blue,
                            ),
                  ],
                ),
                subtitle: Text(
                  time,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // FrappeIcon(
                    //   FrappeIcons.favourite_resting,
                    //   color: FrappePalette.grey,
                    //   size: 20,
                    // ),
                    // SizedBox(
                    //   width: 11,
                    // ),
                    GestureDetector(
                      onTap: () {
                        widget.onReplyTo();
                      },
                      child: FrappeIcon(
                        FrappeIcons.reply_alt,
                        color: FrappePalette.grey,
                        size: 18,
                      ),
                    ),
                    SizedBox(
                      width: 11,
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.onReplyAll();
                      },
                      child: FrappeIcon(
                        FrappeIcons.reply_all,
                      ),
                    ),
                    // SizedBox(
                    //   width: 11,
                    // ),
                    // FrappeIcon(
                    //   FrappeIcons.dot_vertical,
                    // ),
                  ],
                ),
              ),
              Flexible(
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment(0.0, 0.6),
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        _isExpanded ? Colors.white : Colors.white10
                      ],
                    ).createShader(
                        Rect.fromLTRB(0, 0, rect.width, rect.height));
                  },
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Html(
                      data: widget.data.content,
                      customRender: {
                        "img": (renderContext, child) {
                          var src = renderContext.tree.attributes['src'];
                          if (src != null) {
                            if (!src.startsWith("http")) {
                              src = Config().baseUrl! + src;
                            }
                            return GestureDetector(
                              onTap: () => Navigator.of(
                                context,
                                rootNavigator: true,
                              ).push(
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    appBar: AppBar(
                                      elevation: 0.8,
                                    ),
                                    body: PhotoView(
                                      imageProvider: NetworkImage(
                                        src!,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              child: Image.network(
                                src,
                                headers: {
                                  HttpHeaders.cookieHeader: DioHelper.cookies!,
                                },
                              ),
                            );
                          }
                        },
                      },
                      customImageRenders: {
                        networkSourceMatcher(domains: [
                          Config().baseUrl!,
                        ]): networkImageRender(
                          headers: {
                            HttpHeaders.cookieHeader: DioHelper.cookies!,
                          },
                          altWidget: (alt) => Text(alt ?? ""),
                          loadingWidget: () => Text("Loading..."),
                        ),
                        // for relative paths, prefix with a base url
                        (attr, _) =>
                                attr["src"] != null &&
                                !attr["src"]!.startsWith("http"):
                            networkImageRender(
                          headers: {
                            HttpHeaders.cookieHeader: DioHelper.cookies!,
                          },
                          mapUrl: (url) => Config().baseUrl! + url!,
                        ),
                        // Custom placeholder image for broken links
                        networkSourceMatcher():
                            networkImageRender(altWidget: (_) => FrappeLogo()),
                      },
                      onLinkTap: (url, _, __, ___) async {
                        print("Opening $url...");
                        if (url != null) {
                          if (await canLaunch(url)) {
                            await launch(
                              url,
                              headers: {
                                HttpHeaders.cookieHeader: DioHelper.cookies!,
                              },
                            );
                          } else {
                            throw 'Could not launch $url';
                          }
                        }
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ViewEmail extends StatelessWidget {
  final String title;
  final String time;
  final String senderFullName;
  final String sender;
  final String content;

  ViewEmail({
    required this.title,
    required this.time,
    required this.senderFullName,
    required this.sender,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              elevation: 4,
              child: Container(
                color: Palette.bgColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: UserAvatar(
                        uid: sender,
                      ),
                      title: Text(senderFullName),
                      subtitle: Text(time),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8.0),
              child: Html(
                data: content,
                customRender: {
                  "img": (renderContext, child) {
                    var src = renderContext.tree.attributes['src'];
                    if (src != null) {
                      if (!src.startsWith("http")) {
                        src = Config().baseUrl! + src;
                      }
                      return GestureDetector(
                        onTap: () => Navigator.of(
                          context,
                          rootNavigator: true,
                        ).push(
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(
                                elevation: 0.8,
                              ),
                              body: PhotoView(
                                imageProvider: NetworkImage(
                                  src!,
                                ),
                              ),
                            ),
                          ),
                        ),
                        child: Image.network(
                          src,
                          headers: {
                            HttpHeaders.cookieHeader: DioHelper.cookies!,
                          },
                        ),
                      );
                    }
                  },
                },
                customImageRenders: {
                  networkSourceMatcher(domains: [
                    Config().baseUrl!,
                  ]): networkImageRender(
                    headers: {
                      HttpHeaders.cookieHeader: DioHelper.cookies!,
                    },
                    altWidget: (alt) => Text(alt ?? ""),
                    loadingWidget: () => Text("Loading..."),
                  ),
                  // for relative paths, prefix with a base url
                  (attr, _) =>
                      attr["src"] != null &&
                      !attr["src"]!.startsWith("http"): networkImageRender(
                    headers: {
                      HttpHeaders.cookieHeader: DioHelper.cookies!,
                    },
                    mapUrl: (url) => Config().baseUrl! + url!,
                  ),
                  // Custom placeholder image for broken links
                  networkSourceMatcher():
                      networkImageRender(altWidget: (_) => FrappeLogo()),
                },
                onLinkTap: (url, _, __, ___) async {
                  print("Opening $url...");
                  if (url != null) {
                    if (await canLaunch(url)) {
                      await launch(
                        url,
                        headers: {
                          HttpHeaders.cookieHeader: DioHelper.cookies!,
                        },
                      );
                    } else {
                      throw 'Could not launch $url';
                    }
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
