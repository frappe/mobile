import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

import '../../app/locator.dart';
import '../../services/api/api.dart';
import '../../utils/cache_helper.dart';
import '../../utils/config_helper.dart';
import '../../utils/http.dart';

@lazySingleton
class LoginViewModel extends BaseViewModel {
  var savedCreds = {
    "serverUrl": "",
    "usr": "",
    "pwd": "",
  };

  String loginButtonLabel;

  init() {
    loginButtonLabel = "Login";
    var savedUsr = CacheHelper.getCache('usr');
    var savedPwd = CacheHelper.getCache('pwd');
    var serverURL = ConfigHelper().baseUrl;
    savedUsr = savedUsr["data"];
    savedPwd = savedPwd["data"];

    savedCreds = {
      "serverURL": serverURL,
      "usr": savedUsr,
      "pwd": savedPwd,
    };
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
    loginButtonLabel = "Verifying...";
    notifyListeners();
    await setBaseUrl(data["serverURL"]);

    try {
      var response = await locator<Api>().login(
        data["usr"].trimRight(),
        data["pwd"],
      );
      updateConfig(response);
      cacheCreds(data);
      await cacheAllUsers();

      loginButtonLabel = "Success";
      notifyListeners();

      return {
        "success": true,
        "message": "Success",
      };
    } catch (e) {
      ConfigHelper.set('isLoggedIn', false);
      loginButtonLabel = "Login";
      notifyListeners();
      return {
        "success": false,
        "message": e.statusMessage,
        "statusCode": e.statusCode,
      };
    }
  }
}
