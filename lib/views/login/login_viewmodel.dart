import '../../app/locator.dart';
import '../../services/api/api.dart';
import '../../utils/cache_helper.dart';
import '../../utils/config_helper.dart';
import '../../utils/http.dart';

class LoginViewModel {
  getData() async {
    var savedUsr = CacheHelper.getCache('usr');
    var savedPwd = CacheHelper.getCache('pwd');
    savedUsr = savedUsr["data"];
    savedPwd = savedPwd["data"];
    return Future.value({
      "savedUsr": savedUsr,
      "savedPwd": savedPwd,
    });
  }

  updateConfig(response) {
    ConfigHelper.set('isLoggedIn', true);

    ConfigHelper.set(
      'userId',
      response.userId,
    );
    ConfigHelper.set(
      'user',
      response.fullName,
    );
  }

  cacheCreds(data) {
    CacheHelper.putCache(
      'usr',
      data["usr"].trimRight(),
    );
    CacheHelper.putCache(
      'pwd',
      data["pwd"],
    );
  }

  login(data) async {
    await setBaseUrl(data["serverURL"]);

    try {
      var response = await locator<Api>().login(
        data["usr"].trimRight(),
        data["pwd"],
      );
      await cacheAllUsers();

      updateConfig(response);
      cacheCreds(data);
      return {
        "success": true,
        "message": "Success",
      };
    } catch (e) {
      ConfigHelper.set('isLoggedIn', false);
      return {
        "success": false,
        "message": e.statusMessage,
        "statusCode": e.statusCode,
      };
    }
  }
}
