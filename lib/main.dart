import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:frappe_app/service_locator.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import './app.dart';
import './utils/http.dart';

SharedPreferences localStorage;
Box queue;
Box cache;
String primaryCacheKey;

const simpleTaskKey = "simpleTask";
const simpleDelayedTask = "simpleDelayedTask";
const simplePeriodicTask = "simplePeriodicTask";
const simplePeriodic1HourTask = "simplePeriodic1HourTask";
const scheduleDownloadModules = "downloadModules";

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    switch (task) {
      case simpleTaskKey:
        print("$simpleTaskKey was executed. inputData = $inputData");
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("test", true);
        print("Bool from prefs: ${prefs.getBool("test")}");
        break;
      case simpleDelayedTask:
        print("$simpleDelayedTask was executed");
        break;
      case simplePeriodicTask:
        print("$simplePeriodicTask was executed");
        break;
      case simplePeriodic1HourTask:
        print("$simplePeriodic1HourTask was executed");
        break;
      case scheduleDownloadModules:
        print("downloading modules");
        // if (localStorage.containsKey("${baseUrl}activeModules")) {
        //   var activeModules = Map<String, List>.from(
        //     json.decode(
        //       localStorage.getString("${baseUrl}activeModules"),
        //     ),
        //   );

        //   activeModules.forEach((module, doctypes) {
        //     cacheModule(module, context);
        //   });
        // }
        break;
      case Workmanager.iOSBackgroundTask:
        print("The iOS background fetch was triggered");
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        print(
            "You can access other plugins in the background, for example Directory.getTemporaryDirectory(): $tempPath");
        break;
    }

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  Workmanager.initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  await Hive.initFlutter();
  queue = await Hive.openBox('queue');
  cache = await Hive.openBox('cache');
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
