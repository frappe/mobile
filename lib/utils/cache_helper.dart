import '../utils/config_helper.dart';
import '../utils/backend_service.dart';
import '../utils/helpers.dart';

import '../services/storage_service.dart';

import '../service_locator.dart';

class CacheHelper {
  static var cacheContainer = locator<StorageService>().getBox('cache');

  static putCache(String secondaryKey, dynamic data) {
    var k = ConfigHelper().primaryCacheKey + "#@#" + secondaryKey;
    var v = {
      'timestamp': DateTime.now(),
      'data': data,
    };

    cacheContainer.put(k, v);
  }

  static getCache(String secondaryKey) {
    var k = ConfigHelper().primaryCacheKey + "#@#" + secondaryKey;

    if (cacheContainer.get(k) == null) {
      return {"data": null};
    }

    return cacheContainer.get(k);
  }

  static Future remove(String k) async {
    cacheContainer.delete(k);
  }

  static cacheModule(String module) async {
    putCache('module$module', module);
    await cacheDoctypes(module);
  }

  static cacheDoctypes(String module) async {
    var doctypes = await BackendService().getDesktopPage(module);

    var activeDoctypes = getActivatedDoctypes(doctypes, module);

    for (var doctype in activeDoctypes) {
      await cacheDocList(doctype["name"]);
    }
  }

  static cacheDocList(String doctype) async {
    var backendService = BackendService();
    var docMeta = await backendService.getDoctype(doctype);
    docMeta = docMeta["docs"][0];
    await cacheLinkFields(docMeta);
    var docList = await BackendService(meta: docMeta).fetchList(
      fieldnames: generateFieldnames(doctype, docMeta),
      doctype: doctype,
      pageLength: 50,
      offset: 0,
    );

    for (var doc in docList) {
      await cacheForm(doctype, doc["name"]);
    }
  }

  static cacheLinkFields(Map meta) async {
    var linkFieldDoctypes = meta["fields"]
        .where((d) => d["fieldtype"] == 'Link')
        .map((d) => d["options"])
        .toList();
    for (var doctype in linkFieldDoctypes) {
      await BackendService().searchLink(
        doctype: doctype,
        pageLength: 9999,
      );
    }
  }

  static cacheForm(String doctype, String name) async {
    await BackendService().getdoc(doctype, name);
  }
}
