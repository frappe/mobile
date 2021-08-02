import '../app/locator.dart';
import '../services/api/api.dart';

import '../utils/dio_helper.dart';
import '../model/offline_storage.dart';
import '../model/config.dart';

initApiConfig() async {
  if (Config().baseUrl != null) {
    await DioHelper.init(Config().baseUrl!);
    await DioHelper.initCookies();
  }
}

Future<void> cacheAllUsers() async {
  var allUsers = OfflineStorage.getItem('allUsers');
  allUsers = allUsers["data"];
  if (allUsers != null) {
    return;
  } else {
    var fieldNames = [
      "`tabUser`.`name`",
      "`tabUser`.`full_name`",
      "`tabUser`.`user_image`",
    ];

    var filters = [
      ["User", "enabled", "=", 1]
    ];

    try {
      var meta = await locator<Api>().getDoctype('User');

      var res = await locator<Api>().fetchList(
        fieldnames: fieldNames,
        doctype: 'User',
        orderBy: '`tabUser`.`modified` desc',
        filters: filters,
        meta: meta.docs[0],
      );

      var usr = {};
      res.forEach(
        (element) {
          usr[element["name"]] = element;
        },
      );
      OfflineStorage.putItem('allUsers', usr);
    } catch (e) {
      throw e;
    }
  }
}

Future<void> setBaseUrl(url) async {
  if (!url.startsWith('https://')) {
    url = "https://$url";
  }
  await Config.set('baseUrl', url);
  await DioHelper.init(url);
}

String getAbsoluteUrl(String url) {
  return Uri.encodeFull("${Config().baseUrl}$url");
}
