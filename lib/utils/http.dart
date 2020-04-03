import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';

BaseOptions options = new BaseOptions(baseUrl: "http://erpnext.dev2:8000/api");

Dio dio = new Dio(options);

Future cookie() async {
  Directory appDocDir = await getApplicationSupportDirectory();
  String appDocPath = appDocDir.path;

  return PersistCookieJar(
    dir: appDocPath,
    ignoreExpires: true,
  );
}