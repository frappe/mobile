import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'app.dart';
import 'utils/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
    debug: true // optional: set false to disable printing logs to console
  );
  runApp(MyApp());
  var cookieJar = await cookie();
  dio.interceptors.add(CookieManager(cookieJar));
}

Future authenticate(usr, pwd) async {
  final response =
      await dio.post('/method/login', data: {'usr': usr, 'pwd': pwd});
  SharedPreferences localStorage = await SharedPreferences.getInstance();
  localStorage.setBool('isLoggedIn', false);
  if (response.statusCode == 200) {
    localStorage.setBool('isLoggedIn', true);
  }
  return response;
}
