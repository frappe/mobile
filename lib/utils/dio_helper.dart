import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';

import '../model/config.dart';

class DioHelper {
  static Dio dio;
  static String cookies;

  static Future init(String baseUrl) async {
    var cookieJar = await getCookiePath();
    dio = Dio(
      BaseOptions(
        baseUrl: "$baseUrl/api",
      ),
    )..interceptors.add(
        CookieManager(cookieJar),
      );
    dio.options.connectTimeout = 60 * 1000;
    dio.options.receiveTimeout = 60 * 1000;
    cookies = await getCookies();
  }

  static Future<PersistCookieJar> getCookiePath() async {
    Directory appDocDir = await getApplicationSupportDirectory();
    String appDocPath = appDocDir.path;

    return PersistCookieJar(
      dir: appDocPath,
      ignoreExpires: true,
    );
  }

  static Future<String> getCookies() async {
    var cookieJar = await getCookiePath();

    var cookies = cookieJar.loadForRequest(Config().uri);

    var cookie = CookieManager.getCookies(cookies);

    return cookie;
  }
}
