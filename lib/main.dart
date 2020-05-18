import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'app.dart';
import 'utils/http.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
    debug: true // optional: set false to disable printing logs to console
  );
  runApp(FrappeApp());
  var cookieJar = await getCookiePath();
  dio.interceptors.add(CookieManager(cookieJar));
}