import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import 'utils/helpers.dart';
import 'utils/http.dart';

import 'scheduler.dart';
import 'service_locator.dart';
import 'services/storage_service.dart';
import 'app.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();

  await putSharedPrefValue("backgroundTask", false);
  await putSharedPrefValue("cacheApi", true);

  await locator<StorageService>().initStorage();

  await locator<StorageService>().initBox('queue');
  await locator<StorageService>().initBox('cache');
  await locator<StorageService>().initBox('config');
  await FlutterDownloader.initialize(
      debug: kReleaseMode == true
          ? false
          : true // optional: set false to disable printing logs to console
      );
  await initConfig();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
    iOS: initializationSettingsIOS,
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
  // var packageInfo = await PackageInfo.fromPlatform();
  // var currentVersion = ConfigHelper().version;
  // if (currentVersion == null || packageInfo.version != currentVersion) {
  //   ConfigHelper.clear();
  // }
  // ConfigHelper.set('version', packageInfo.version);
  await initAutoSync(kReleaseMode == true ? false : true);
  // TODO: move to main thread, as background tasks will be disabled when app is active
  // Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
  // Use Connectivity() here to gather more info if you need t

  // Workmanager.registerOneOffTask(
  //   SYNC_DATA_TASK_UNIQUE_NAME,
  //   TASK_SYNC_DATA,
  //   constraints: Constraints(
  //     networkType: NetworkType.connected,
  //     requiresBatteryNotLow: false,
  //   ),
  //   existingWorkPolicy: ExistingWorkPolicy.replace,
  // );

  // Workmanager.registerOneOffTask(
  //   "103",
  //   "processQueue2",
  //   constraints: Constraints(
  //     networkType: NetworkType.connected,
  //     requiresBatteryNotLow: false,
  //   ),
  //   existingWorkPolicy: ExistingWorkPolicy.keep,
  // );
  // });

  runApp(FrappeApp());
}
