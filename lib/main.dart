import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './app.dart';
import './utils/http.dart';

SharedPreferences localStorage;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  localStorage = await SharedPreferences.getInstance();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );
  await initConfig();
  var packageInfo = await PackageInfo.fromPlatform();
  var currentVersion = localStorage.getString('version');
  if (currentVersion == null || packageInfo.version != currentVersion) {
    localStorage.clear();
  }
  localStorage.setString('version', packageInfo.version);
  runApp(FrappeApp());
}
