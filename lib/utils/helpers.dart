import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frappe_app/app/router.gr.dart';
import 'package:frappe_app/model/offline_storage.dart';
import 'package:frappe_app/services/storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/config.dart';
import '../model/doctype_response.dart';

import '../services/api/api.dart';
import '../views/no_internet.dart';

import 'http.dart';
import '../main.dart';
import '../form/controls/control.dart';
import '../app/locator.dart';
import '../config/palette.dart';
import '../services/navigation_service.dart';

import '../utils/dio_helper.dart';
import '../utils/enums.dart';

import '../widgets/section.dart';
import '../widgets/custom_expansion_tile.dart';

// TODO
Widget buildDecoratedWidget(Widget fieldWidget, bool withLabel,
    [String label = ""]) {
  if (withLabel) {
    return Padding(
      padding: Palette.fieldPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: Palette.labelPadding,
            child: Text(
              label ?? "",
              style: Palette.secondaryTxtStyle,
            ),
          ),
          fieldWidget
        ],
      ),
    );
  } else {
    return Padding(
      padding: Palette.fieldPadding,
      child: fieldWidget,
    );
  }
}

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
      HttpHeaders.cookieHeader: await DioHelper.getCookies(),
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
  // TODO
  return true;
  // if (Platform.isAndroid) {
  //   PermissionStatus permission = await PermissionHandler()
  //       .checkPermissionStatus(PermissionGroup.storage);
  //   if (permission != PermissionStatus.granted) {
  //     Map<PermissionGroup, PermissionStatus> permissions =
  //         await PermissionHandler()
  //             .requestPermissions([PermissionGroup.storage]);
  //     if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
  //       return true;
  //     }
  //   } else {
  //     return true;
  //   }
  // } else {
  //   return true;
  // }
  // return false;
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

void showSnackBar(String txt, context) {
  Scaffold.of(context).showSnackBar(
    SnackBar(
      content: Text(txt),
    ),
  );
}

List<Widget> generateLayout({
  @required List<DoctypeField> fields,
  @required ViewType viewType,
  Map doc,
  bool editMode = true,
  bool withLabel = true,
  Function onChanged,
}) {
  List<Widget> collapsibles = [];
  List<Widget> sections = [];
  List<Widget> widgets = [];

  List<String> collapsibleLabels = [];
  List<String> sectionLabels = [];

  bool isCollapsible = false;
  bool isSection = false;

  int cIdx = 0;
  int sIdx = 0;

  fields.forEach((field) {
    var val = doc != null
        ? doc[field.fieldname] ?? field.defaultValue
        : field.defaultValue;

    if (val == '__user') {
      val = Config().userId;
    }

    if (val is List) {
      if (val.isEmpty) {
        val = null;
      }
    }

    if (field.fieldtype == "Section Break") {
      if (sections.length > 0) {
        var sectionVisibility = sections.any((element) {
          if (element is Visibility) {
            return element.visible == true;
          } else {
            return true;
          }
        });

        widgets.add(
          Visibility(
            visible: sectionVisibility,
            child: sectionLabels[sIdx] != ''
                ? ListTileTheme(
                    contentPadding: EdgeInsets.all(0),
                    child: CustomExpansionTile(
                      maintainState: true,
                      initiallyExpanded: true,
                      title: Text(
                        sectionLabels[sIdx].toUpperCase(),
                        style: Palette.secondaryTxtStyle,
                      ),
                      children: [...sections],
                    ),
                  )
                : Section(
                    title: sectionLabels[sIdx],
                    children: [...sections],
                  ),
          ),
        );

        sIdx += 1;
        sections.clear();
      } else if (collapsibles.length > 0) {
        var sectionVisibility = collapsibles.any((element) {
          if (element is Visibility) {
            return element.visible == true;
          } else {
            return true;
          }
        });
        widgets.add(
          Visibility(
            visible: sectionVisibility,
            child: ListTileTheme(
              contentPadding: EdgeInsets.all(0),
              child: CustomExpansionTile(
                maintainState: true,
                title: Text(
                  collapsibleLabels[cIdx].toUpperCase(),
                  style: Palette.secondaryTxtStyle,
                ),
                children: [...collapsibles],
              ),
            ),
          ),
        );
        cIdx += 1;
        collapsibles.clear();
      }

      if (field.collapsible == 1) {
        isSection = false;
        isCollapsible = true;
        collapsibleLabels.add(field.label);
      } else {
        isCollapsible = false;
        isSection = true;
        sectionLabels.add(field.label != null ? field.label.toUpperCase() : '');
      }
    } else if (isCollapsible) {
      if (viewType == ViewType.form) {
        collapsibles.add(
          Visibility(
            visible: editMode ? true : val != null && val != '',
            child: makeControl(
              field: field,
              value: val,
              doc: doc,
              withLabel: withLabel,
              editMode: editMode,
              onChanged: onChanged,
            ),
          ),
        );
      } else {
        collapsibles.add(
          makeControl(
            doc: doc,
            field: field,
            value: val,
            withLabel: withLabel,
            editMode: editMode,
            onChanged: onChanged,
          ),
        );
      }
    } else if (isSection) {
      if (viewType == ViewType.form) {
        sections.add(
          Visibility(
            visible: editMode ? true : val != null && val != '',
            child: makeControl(
              doc: doc,
              field: field,
              value: val,
              withLabel: withLabel,
              editMode: editMode,
              onChanged: onChanged,
            ),
          ),
        );
      } else {
        sections.add(
          makeControl(
            field: field,
            doc: doc,
            value: val,
            withLabel: withLabel,
            editMode: editMode,
            onChanged: onChanged,
          ),
        );
      }
    } else {
      if (viewType == ViewType.form) {
        widgets.add(
          Visibility(
            visible: editMode ? true : val != null && val != '',
            child: makeControl(
              doc: doc,
              field: field,
              value: val,
              withLabel: withLabel,
              editMode: editMode,
              onChanged: onChanged,
            ),
          ),
        );
      } else {
        widgets.add(
          makeControl(
            field: field,
            value: val,
            doc: doc,
            withLabel: withLabel,
            editMode: editMode,
            onChanged: onChanged,
          ),
        );
      }
    }
  });

  return widgets;
}

DateTime parseDate(val) {
  if (val == null) {
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
  await DioHelper.getCookiePath()
    ..delete(
      Config().uri,
    );
  Config.set('isLoggedIn', false);
}

handle403() async {
  await clearLoginInfo();
  locator<NavigationService>().clearAllAndNavigateTo(Routes.sessionExpired);
}

handleError(Response error, [bool hideAppBar = false]) {
  if (error.statusCode == HttpStatus.forbidden) {
    handle403();
  } else if (error.statusCode == HttpStatus.serviceUnavailable) {
    return NoInternet(hideAppBar);
  } else {
    return Scaffold(appBar: AppBar(), body: Text("${error.statusMessage}"));
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

showErrorDialog(e, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(e.statusMessage),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () async {
              locator<NavigationService>().pop();
            },
          ),
        ],
      );
    },
  );
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

requestIOSLocationAuthorization(connectivity) async {
  try {
    if (Platform.isIOS) {
      LocationAuthorizationStatus status =
          await connectivity.getLocationServiceAuthorization();
      if (status == LocationAuthorizationStatus.notDetermined) {
        status = await connectivity.requestLocationServiceAuthorization();
      } else {
        return {
          "access": true,
        };
      }
    }
  } on PlatformException catch (e) {
    print(e.toString());
    return {
      "access": false,
    };
  }
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

putSharedPrefValue(String key, bool value) async {
  var _prefs = await SharedPreferences.getInstance();
  await _prefs.setBool(key, value);
}

Future<bool> getSharedPrefValue(String key) async {
  var _prefs = await SharedPreferences.getInstance();
  await _prefs.reload();
  return _prefs.getBool(key);
}

resetValues() async {
  await putSharedPrefValue("backgroundTask", false);
  await putSharedPrefValue("storeApiResponse", true);
}

initDb() async {
  await locator<StorageService>().initStorage();

  await locator<StorageService>().initBox('queue');
  await locator<StorageService>().initBox('offline');
  await locator<StorageService>().initBox('config');
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
    var desktopPage = await locator<Api>().getDesktopPage(item.label);

    desktopPage.message.cards.items.forEach(
      (item) {
        var doctypes = [];
        item.links.forEach(
          (link) {
            doctypes.add(link.label);
          },
        );

        moduleDoctypesMapping[item.label] = doctypes;
      },
    );
  }

  OfflineStorage.putItem('awesomeItems', moduleDoctypesMapping);
}
