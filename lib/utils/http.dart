import '../app/locator.dart';
import '../services/api/api.dart';

import '../utils/dio_helper.dart';
import '../utils/cache_helper.dart';
import '../utils/config_helper.dart';

void initConfig() async {
  if (ConfigHelper().baseUrl != null) {
    await DioHelper.init(ConfigHelper().baseUrl);
  }
}

Future<void> cacheAllUsers() async {
  var allUsers = await CacheHelper.getCache('allUsers');
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

    var meta = await locator<Api>().getDoctype('User');

    var res = await locator<Api>().fetchList(
      fieldnames: fieldNames,
      doctype: 'User',
      filters: filters,
      meta: meta.docs[0],
    );

    var usr = {};
    res.forEach((element) {
      usr[element["name"]] = element;
    });
    CacheHelper.putCache('allUsers', usr);
  }
}

Future<void> setBaseUrl(url) async {
  if (!url.startsWith('https://')) {
    url = "https://$url";
  }
  await ConfigHelper.set('baseUrl', url);
  await DioHelper.init(url);
}

String getAbsoluteUrl(String url) {
  return Uri.encodeFull("${ConfigHelper().baseUrl}$url");
}
