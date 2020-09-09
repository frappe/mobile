import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:frappe_app/form/controls/control.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/section.dart';
import '../widgets/custom_expansion_tile.dart';
import '../utils/backend_service.dart';
import '../config/palette.dart';

import '../utils/enums.dart';
import '../main.dart';
import '../app.dart';
import './http.dart';

logout(context) async {
  var cookieJar = await getCookiePath();

  cookieJar.delete(uri);

  localStorage.setBool('isLoggedIn', false);

  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (BuildContext context) {
        return FrappeApp();
      },
    ),
    (_) => false,
  );
}

Future processData({
  String doctype,
  context,
  bool offline = false,
}) async {
  var meta;

  if (offline) {
    meta = getCache('${doctype}Meta')["data"];
  } else {
    meta = await BackendService(context).getDoctype(doctype);
  }

  List metaFields = meta["docs"][0]["fields"];

  metaFields.forEach((field) {
    meta["docs"][0]["_field${field["fieldname"]}"] = true;
  });

  localStorage.setString('${doctype}Meta', json.encode(meta));

  return meta;
}

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
              label,
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
      HttpHeaders.cookieHeader: await getCookies(),
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
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
        return true;
      }
    } else {
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

void showSnackBar(String txt, context) {
  Scaffold.of(context).showSnackBar(
    SnackBar(
      content: Text(txt),
    ),
  );
}

List<Widget> generateLayout({
  @required List fields,
  @required ViewType viewType,
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
    var val = field["_current_val"] ?? field["default"];

    if (val == '__user') {
      val = Uri.decodeFull(localStorage.getString('userId'));
    }

    if (field["fieldtype"] == "Section Break") {
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

      if (field["collapsible"] == 1) {
        isSection = false;
        isCollapsible = true;
        collapsibleLabels.add(field["label"]);
      } else {
        isCollapsible = false;
        isSection = true;
        sectionLabels
            .add(field["label"] != null ? field["label"].toUpperCase() : '');
      }
    } else if (isCollapsible) {
      if (viewType == ViewType.form) {
        collapsibles.add(
          Visibility(
            visible: editMode ? true : val != null && val != '',
            child: makeControl(
              field: field,
              value: val,
              withLabel: withLabel,
              editMode: editMode,
              onChanged: onChanged,
            ),
          ),
        );
      } else {
        collapsibles.add(
          makeControl(
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

List generateFieldnames(String doctype, Map meta) {
  var fields = [
    'name',
    'modified',
    '_assign',
    '_seen',
    '_liked_by',
    '_comments',
  ];

  if (meta["title_field"] != null) {
    fields.add(meta["title_field"]);
  }

  if (hasField(meta, 'status')) {
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

bool hasField(Map meta, String fieldName) {
  return meta.containsKey('_field$fieldName');
}

bool isSubmittable(Map meta) {
  return meta["is_submittable"] == 1;
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

getActivatedDoctypes(Map doctypes, String module) {
  var activeModules = Map<String, List>.from(
    json.decode(
      localStorage.getString("${baseUrl}activeModules"),
    ),
  );
  var activeDoctypes = [];

  doctypes["message"]["cards"]["items"].forEach((item) {
    activeDoctypes.addAll(item["links"]);
  });
  activeDoctypes = activeDoctypes.where((m) {
    return activeModules[module].contains(
      m["name"],
    );
  }).toList();

  return activeDoctypes;
}

putCache(String secondaryKey, dynamic data) {
  var k = primaryCacheKey + "#@#" + secondaryKey;
  var v = {
    'timestamp': DateTime.now(),
    'data': data,
  };

  cache.put(k, v);
}

getCache(String secondaryKey) {
  var k = primaryCacheKey + "#@#" + secondaryKey;
  return cache.get(k);
}

cacheModule(String module, context) async {
  putCache('module$module', module);
  await cacheDoctypes(module, context);
}

cacheDoctypes(String module, context) async {
  var doctypes = await BackendService(context).getDesktopPage(module, context);

  var activeDoctypes = getActivatedDoctypes(doctypes, module);

  for (var doctype in activeDoctypes) {
    await cacheDocList(doctype["name"], context);
  }
}

cacheDocList(String doctype, context) async {
  var backendService = BackendService(context);
  var docMeta = await backendService.getDoctype(doctype);
  docMeta = docMeta["docs"][0];
  await cacheLinkFields(docMeta, context);
  var docList = await BackendService(context, meta: docMeta).fetchList(
    fieldnames: generateFieldnames(doctype, docMeta),
    doctype: doctype,
    pageLength: 50,
    offset: 0,
  );

  for (var doc in docList) {
    await cacheForm(doctype, doc["name"], context);
  }
}

cacheLinkFields(Map meta, context) async {
  var linkFieldDoctypes = meta["fields"]
      .where((d) => d["fieldtype"] == 'Link')
      .map((d) => d["options"])
      .toList();
  for (var doctype in linkFieldDoctypes) {
    await BackendService(context).searchLink(
      doctype: doctype,
      pageLength: 9999,
    );
  }
}

cacheForm(String doctype, String name, context) async {
  await BackendService(context).getdoc(doctype, name);
}
