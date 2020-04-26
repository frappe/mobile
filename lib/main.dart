
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'utils/http.dart';
import 'routes/issue.dart';

void main() async {
  runApp(MyApp());
  var cookieJar = await cookie();
  dio.interceptors.add(CookieManager(cookieJar));
}

Future authenticate(usr, pwd) async {
  final response =
      await dio.post('/method/login', data: {'usr': usr, 'pwd': pwd});

  print(response);
  return response;
}