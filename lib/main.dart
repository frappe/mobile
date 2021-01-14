import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'utils/helpers.dart';
import 'utils/http.dart';

import 'scheduler.dart';
import 'app/locator.dart';
import 'app.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupLocator();
  await resetValues();
  await initDb();
  await FlutterDownloader.initialize();
  await initApiConfig();
  await initLocatlNotifications();
  await initAutoSync();

  runApp(FrappeApp());
}
