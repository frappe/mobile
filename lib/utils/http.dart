import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:frappe_app/utils/backend_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';

import '../main.dart';

Dio dio;
Uri uri;
var baseUrl;
String cookies;

void initConfig() async {
  if (localStorage.containsKey('serverURL')) {
    uri = Uri.parse(localStorage.getString('serverURL'));
    baseUrl = uri.origin;
    BaseOptions options = new BaseOptions(baseUrl: "$baseUrl/api");
    dio = Dio(options);
    var cookieJar = await getCookiePath();
    dio.interceptors.add(CookieManager(cookieJar));
    cookies = await getCookies();
  }
}

void cacheAllUsers(context) async {
  if (localStorage.containsKey('${baseUrl}allUsers')) {
    return;
  } else {
    var fieldNames = [
      "`tabUser`.`name`",
      "`tabUser`.`full_name`",
      "`tabUser`.`user_image`",
    ];

    var filters = [
      ["User", "enabled", "=", 1]
    ];

    var res = await BackendService(context).fetchList(
      fieldnames: fieldNames,
      doctype: 'User',
      filters: filters,
    );

    var usr = {};
    res.forEach((element) {
      usr[element["name"]] = element;
    });
    localStorage.setString('${baseUrl}allUsers', json.encode(usr));
  }
}

void setBaseUrl(url) async {
  if (!url.startsWith('https://')) {
    url = "https://$url";
  }
  baseUrl = url;
  BaseOptions options = new BaseOptions(baseUrl: "$url/api");
  dio = Dio(options);

  var cookieJar = await getCookiePath();
  dio.interceptors.add(CookieManager(cookieJar));

  uri = Uri.parse(url);

  localStorage.setString('serverURL', url);
}

Future getCookiePath() async {
  Directory appDocDir = await getApplicationSupportDirectory();
  String appDocPath = appDocDir.path;

  return PersistCookieJar(
    dir: appDocPath,
    ignoreExpires: true,
  );
}

Future<String> getCookies() async {
  var cookieJar = await getCookiePath();

  var cookies = cookieJar.loadForRequest(uri);

  var cookie = CookieManager.getCookies(cookies);

  return cookie;
}

String getAbsoluteUrl(String url) {
  return Uri.encodeFull("$baseUrl$url");
}
