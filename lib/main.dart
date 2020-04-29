
import 'dart:convert';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'utils/http.dart';
import 'routes/issue.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() async {
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
