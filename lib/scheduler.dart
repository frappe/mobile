import 'package:frappe_app/utils/config_helper.dart';
import 'package:workmanager/workmanager.dart';

import 'utils/cache_helper.dart';
import 'utils/http.dart';
import 'service_locator.dart';
import 'services/storage_service.dart';

const String TASK_SYNC_DATA = 'downloadModules';
const String SYNC_DATA_TASK_UNIQUE_NAME = '101';
const String SYNC_DATA_TASK_TAG = 'sync_data_task_tag';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    switch (task) {
      case TASK_SYNC_DATA:
        print("$task was executed. inputData = $inputData");
        await syncnow();
        print('Sync complete');

        break;
    }
    return Future.value(true);
  });
}

initAutoSync(bool isDebugMode) async {
  await Workmanager.initialize(
    callbackDispatcher,
    isInDebugMode: isDebugMode,
  );
  registerPeriodicTask();
}

void registerPeriodicTask() {
  Workmanager.registerPeriodicTask(
    SYNC_DATA_TASK_UNIQUE_NAME,
    TASK_SYNC_DATA,
    tag: SYNC_DATA_TASK_TAG,
    frequency: Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: false,
    ),
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );
}

Future syncnow() async {
  if (ConfigHelper().isLoggedIn) {
    print("downloading modules2");
    setupLocator();
    await locator<StorageService>().initStorage();
    await locator<StorageService>().initBox('queue');
    await locator<StorageService>().initBox('cache');
    await locator<StorageService>().initBox('config');
    await initConfig();

    if (ConfigHelper().activeModules != null) {
      var activeModules = ConfigHelper().activeModules;

      for (var module in activeModules.keys) {
        await CacheHelper.cacheModule(module);
      }
      return Future.value(true);
    }
  } else {
    print('not logged in');
    return Future.value(true);
  }
}
