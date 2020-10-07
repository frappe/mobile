import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';

import 'config_helper.dart';

class DioHelper {
  static Dio dio;
  static String cookies;
  static DioCacheManager _manager;

  static Future init(String baseUrl) async {
    var cookieJar = await getCookiePath();
    dio = Dio(
      BaseOptions(
        baseUrl: "$baseUrl/api",
      ),
    )
      ..interceptors.add(
        CookieManager(cookieJar),
      )
      ..interceptors.add(getCacheManager(baseUrl).interceptor);
    cookies = await getCookies();
  }

  static DioCacheManager getCacheManager(String baseUrl) {
    if (_manager == null) {
      _manager = DioCacheManager(CacheConfig(baseUrl: baseUrl));
    }
    return _manager;
  }

  static Future getCookiePath() async {
    Directory appDocDir = await getApplicationSupportDirectory();
    String appDocPath = appDocDir.path;

    return PersistCookieJar(
      dir: appDocPath,
      ignoreExpires: true,
    );
  }

  static Future<String> getCookies() async {
    var cookieJar = await getCookiePath();

    var cookies = cookieJar.loadForRequest(ConfigHelper().uri);

    var cookie = CookieManager.getCookies(cookies);

    return cookie;
  }
}
