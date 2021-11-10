// @dart=2.9
import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/model/offline_storage.dart';
import 'package:frappe_app/services/storage_service.dart';
import 'package:frappe_app/utils/frappe_alert.dart';
import 'package:frappe_app/utils/navigation_helper.dart';
import 'package:frappe_app/views/login/login_view.dart';
import 'package:frappe_app/widgets/frappe_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/config.dart';
import '../model/doctype_response.dart';

import '../services/api/api.dart';
import '../views/no_internet.dart';

import 'http.dart';
import '../main.dart';
import '../app/locator.dart';

import '../utils/dio_helper.dart';
import '../utils/enums.dart';

getDownloadPath() async {
  // TODO
  if (Platform.isAndroid) {
    return '/storage/emulated/0/Download/';
  } else if (Platform.isIOS) {
    final Directory downloadsDirectory =
        await getApplicationDocumentsDirectory();
    return downloadsDirectory.path;
  }
}

downloadFile(String fileUrl, String downloadPath) async {
  await _checkPermission();

  final absoluteUrl = getAbsoluteUrl(fileUrl);

  await FlutterDownloader.enqueue(
    headers: {
      HttpHeaders.cookieHeader: DioHelper.cookies,
    },
    url: absoluteUrl,
    savedDir: downloadPath,
    showNotification:
        true, // show download progress in status bar (for Android)
    openFileFromNotification:
        true, // click on notification to open downloaded file (for Android)
  );
}

Future<bool> _checkPermission() async {
  if (Platform.isAndroid) {
    if (await Permission.storage.request().isGranted) {
      return true;
    }
  } else {
    return true;
  }
  return false;
}

String toTitleCase(String str) {
  return str
      .replaceAllMapped(
          RegExp(
              r'[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+'),
          (Match m) =>
              "${m[0][0].toUpperCase()}${m[0].substring(1).toLowerCase()}")
      .replaceAll(RegExp(r'(_|-)+'), ' ');
}

DateTime parseDate(val) {
  if (val == null || val == "") {
    return null;
  } else if (val == "Today") {
    return DateTime.now();
  } else {
    return DateTime.parse(val);
  }
}

List generateFieldnames(String doctype, DoctypeDoc meta) {
  var fields = [
    'name',
    'modified',
    '_assign',
    '_seen',
    '_liked_by',
    '_comments',
  ];

  if (hasTitle(meta)) {
    fields.add(meta.titleField);
  }

  if (meta.fieldsMap.containsKey('status')) {
    fields.add('status');
  } else {
    fields.add('docstatus');
  }

  var transformedFields = fields.map((field) {
    return "`tab$doctype`.`$field`";
  }).toList();

  return transformedFields;
}

String getInitials(String txt) {
  List<String> names = txt.split(" ");
  String initials = "";
  int numWords = 2;

  if (names.length < numWords) {
    numWords = names.length;
  }
  for (var i = 0; i < numWords; i++) {
    initials += names[i] != '' ? '${names[i][0].toUpperCase()}' : "";
  }
  return initials;
}

bool isSubmittable(DoctypeDoc meta) {
  return meta.isSubmittable == 1;
}

List sortBy(List data, String orderBy, Order order) {
  if (order == Order.asc) {
    data.sort((a, b) {
      return a[orderBy].compareTo(b[orderBy]);
    });
  } else {
    data.sort((a, b) {
      return b[orderBy].compareTo(a[orderBy]);
    });
  }

  return data;
}

bool hasTitle(DoctypeDoc meta) {
  return meta.titleField != null && meta.titleField != '';
}

getTitle(DoctypeDoc meta, Map doc) {
  if (hasTitle(meta)) {
    return doc[meta.titleField];
  } else {
    return doc["name"];
  }
}

clearLoginInfo() async {
  var cookie = await DioHelper.getCookiePath();
  if (Config().uri != null) {
    cookie.delete(
      Config().uri,
    );
  }

  Config.set('isLoggedIn', false);
}

handle403(BuildContext context) async {
  await clearLoginInfo();

  NavigationHelper.clearAllAndNavigateTo(
    context: context,
    page: Login(),
  );
}

handleError({
  @required ErrorResponse error,
  @required BuildContext context,
  Function onRetry,
  bool hideAppBar = false,
}) {
  if (error.statusCode == HttpStatus.forbidden) {
    handle403(context);
  } else if (error.statusCode == HttpStatus.serviceUnavailable) {
    return NoInternet(hideAppBar);
  } else {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${error.statusMessage}"),
            if (onRetry != null)
              FrappeFlatButton(
                onPressed: () => onRetry(),
                buttonType: ButtonType.primary,
                title: "Retry",
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> showNotification({
  @required String title,
  @required String subtitle,
  int index = 0,
}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'FrappeChannelId',
    'FrappeChannelName',
    'FrappeChannelDescription',
    // importance: Importance.max,
    // priority: Priority.high,
    ticker: 'ticker',
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    index,
    title,
    subtitle,
    platformChannelSpecifics,
  );
}

Future<int> getActiveNotifications() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  if (!(androidInfo.version.sdkInt >= 23)) {
    return 0;
  }

  final List<ActiveNotification> activeNotifications =
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.getActiveNotifications();

  return activeNotifications.length;
}

Map extractChangedValues(Map original, Map updated) {
  var changedValues = {};
  for (var key in updated.keys) {
    if (original[key] != updated[key]) {
      changedValues[key] = updated[key];
    }
  }
  return changedValues;
}

Future<bool> verifyOnline() async {
  bool isOnline = false;
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      isOnline = true;
    } else
      isOnline = false;
  } on SocketException catch (_) {
    isOnline = false;
  }

  return isOnline;
}

getLinkFields(String doctype) async {
  var docMeta = await locator<Api>().getDoctype(
    doctype,
  );
  var doc = docMeta.docs[0];
  var linkFieldDoctypes = doc.fields
      .where((d) => d.fieldtype == 'Link')
      .map((d) => d.options)
      .toList();

  return linkFieldDoctypes;
}

resetValues() async {
  await locator<StorageService>()
      .putSharedPrefBoolValue("backgroundTask", false);
  await locator<StorageService>()
      .putSharedPrefBoolValue("storeApiResponse", true);
}

initDb() async {
  await locator<StorageService>().initHiveStorage();

  await locator<StorageService>().initHiveBox('queue');
  await locator<StorageService>().initHiveBox('offline');
  await locator<StorageService>().initHiveBox('config');
}

initLocalNotifications() async {
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
}

initAwesomeItems() async {
  var deskSidebarItems = await locator<Api>().getDeskSideBarItems();
  var moduleDoctypesMapping = {};

  for (var item in deskSidebarItems.message) {
    String module;
    if (item.content != null) {
      module = jsonEncode({
        "name": item.name,
        "title": item.name,
        "content": item.content,
      });
    } else {
      module = item.name;
    }

    var desktopPage = await locator<Api>().getDesktopPage(module);

    var doctypes = [];
    desktopPage.message.cards.items.forEach(
      (item) {
        item.links.forEach(
          (link) {
            doctypes.add(link.label);
          },
        );
      },
    );
    moduleDoctypesMapping[item.label] = doctypes;
  }

  OfflineStorage.putItem('awesomeItems', moduleDoctypesMapping);
}

noInternetAlert(
  BuildContext context,
) {
  FrappeAlert.warnAlert(
    title: "Connection Lost",
    subtitle: "You are not connected to Internet. Retry after sometime.",
    context: context,
  );
}

executeJS({
  @required String jsString,
}) {
  JavascriptRuntime flutterJs = getJavascriptRuntime();
  try {
    JsEvalResult jsResult = flutterJs.evaluate(jsString);
    return jsResult.rawResult;
  } on PlatformException catch (e) {
    print('ERRO: ${e.details}');
  }
}

String getServerMessage(String serverMsgs) {
  var errorMsgs = json.decode(serverMsgs) as List;
  var errorStr = '';
  errorMsgs.forEach((errorMsg) {
    errorStr += json.decode(errorMsg)["message"];
  });

  return errorStr;
}
