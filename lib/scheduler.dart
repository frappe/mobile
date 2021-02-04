import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frappe_app/utils/config_helper.dart';
import 'package:frappe_app/utils/helpers.dart';
import 'package:frappe_app/model/queue.dart';
import 'package:workmanager/workmanager.dart';

import 'model/offline_storage.dart';
import 'utils/http.dart';
import 'app/locator.dart';
import 'services/storage_service.dart';

const String TASK_SYNC_DATA = 'downloadModules';
const String TASK_PROCESS_QUEUE = 'processQueue';
const String SYNC_DATA_TASK_UNIQUE_NAME = '101';
const String PROCESS_QUEUE_UNIQUE_NAME = '102';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    setupLocator();
    await locator<StorageService>().initStorage();
    await locator<StorageService>().initBox('config');
    await locator<StorageService>().initBox('queue');
    await locator<StorageService>().initBox('offline');

    await initApiConfig();

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: initializationSettingsIOS,
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    var notificationCount = await getActiveNotifications();
    var runBackgroundTask = await getSharedPrefValue("backgroundTask");

    if (ConfigHelper().isLoggedIn && runBackgroundTask) {
      switch (task) {
        case TASK_SYNC_DATA:
          await putSharedPrefValue(
            "storeApiResponse",
            false,
          );

          await showNotification(
            title: "Sync",
            subtitle: "Downloading Modules",
            index: notificationCount,
          );
          print("$task was executed");
          try {
            await syncnow();
            print('Sync complete');
            await putSharedPrefValue(
              "storeApiResponse",
              true,
            );
            await showNotification(
              title: "Sync",
              subtitle: "Downloading Modules Completed",
              index: notificationCount,
            );
          } catch (e) {
            await putSharedPrefValue(
              "storeApiResponse",
              true,
            );
            await showNotification(
              title: "Sync",
              subtitle: "Downloading Modules Failed",
              index: notificationCount,
            );
          }

          break;

        case TASK_PROCESS_QUEUE:
          print('process queue started');
          await showNotification(
            title: "Queue",
            subtitle: "Processing Queue",
            index: notificationCount,
          );
          try {
            await Queue.processQueue();
          } catch (e) {
            await showNotification(
              title: "Queue",
              subtitle: "Processing Queue Failed",
              index: notificationCount,
            );
          }
          await showNotification(
            title: "Queue",
            subtitle: "Processing Queue Completed",
            index: notificationCount,
          );
          break;

        case "processQueue2":
          print('process queue started');
          await showNotification(
            title: "Queue",
            subtitle: "Processing Queue",
            index: notificationCount,
          );
          try {
            await Queue.processQueue();
          } catch (e) {
            await showNotification(
              title: "Queue",
              subtitle: "Processing Queue Failed",
              index: notificationCount,
            );
          }
          await showNotification(
            title: "Queue",
            subtitle: "Processing Queue Completed",
            index: notificationCount,
          );
          break;
      }
      return Future.value(true);
    } else {
      print('not logged in');
      return Future.value(true);
    }
  });
}

initAutoSync({bool debug = false}) async {
  await Workmanager.initialize(
    callbackDispatcher,
    isInDebugMode: debug,
  );
  registerPeriodicTask();
}

void registerPeriodicTask() {
  Workmanager.registerPeriodicTask(
    SYNC_DATA_TASK_UNIQUE_NAME,
    TASK_SYNC_DATA,
    frequency: Duration(minutes: 30),
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: false,
    ),
    existingWorkPolicy: ExistingWorkPolicy.keep,
    backoffPolicy: BackoffPolicy.linear,
  );

  Workmanager.registerPeriodicTask(
    PROCESS_QUEUE_UNIQUE_NAME,
    TASK_PROCESS_QUEUE,
    frequency: Duration(minutes: 30),
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: false,
    ),
    existingWorkPolicy: ExistingWorkPolicy.keep,
    backoffPolicy: BackoffPolicy.linear,
  );
}

Future syncnow() async {
  print("downloading modules2");

  if (ConfigHelper().activeModules != null) {
    var activeModules = ConfigHelper().activeModules;

    for (var module in activeModules.keys) {
      var runBackgroundTask = await getSharedPrefValue("backgroundTask");
      if (activeModules[module].isNotEmpty && runBackgroundTask) {
        try {
          await OfflineStorage.storeModule(module, true);
        } catch (e) {
          throw e;
        }
      }
    }
  }
}
