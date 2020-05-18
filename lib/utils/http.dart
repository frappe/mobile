import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';

final String baseUrl = "https://version13beta.erpnext.com";

BaseOptions options =
    new BaseOptions(baseUrl: "$baseUrl/api");
// BaseOptions options = new BaseOptions(baseUrl: "https://mycom.erpnext.com/api");
// BaseOptions options = new BaseOptions(baseUrl: "http://erpnext.dev2:8000/api");

Dio dio = new Dio(options);

Future getCookiePath() async {
  Directory appDocDir = await getApplicationSupportDirectory();
  String appDocPath = appDocDir.path;

  return PersistCookieJar(
    dir: appDocPath,
    ignoreExpires: true,
  );
}

Future<Map<String, String>> getCookiesWithHeader() async {
  var cookieJar = await getCookiePath();

  var cookies = cookieJar.loadForRequest(Uri(
      scheme: "https",
      // port: int.parse("8000", radix: 16),
      host: "version13beta.erpnext.com"));

  var cookie = CookieManager.getCookies(cookies);

  return {
    HttpHeaders.cookieHeader: cookie,
  };
}

String getAbsoluteUrl(String url) {
  return Uri.encodeFull("$baseUrl$url");
}
