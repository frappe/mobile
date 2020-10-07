import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_downloader/flutter_downloader.dart';

import 'scheduler.dart';
import 'service_locator.dart';
import 'services/storage_service.dart';
import 'app.dart';
import 'utils/http.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
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
  // var packageInfo = await PackageInfo.fromPlatform();
  // var currentVersion = ConfigHelper().version;
  // if (currentVersion == null || packageInfo.version != currentVersion) {
  //   ConfigHelper.clear();
  // }
  // ConfigHelper.set('version', packageInfo.version);
  await initAutoSync(kReleaseMode == true ? false : true);
  runApp(FrappeApp());
}
