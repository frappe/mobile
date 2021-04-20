// @dart=2.9
import 'package:injectable/injectable.dart';

import '../../app/locator.dart';
import '../../services/api/api.dart';
import '../../model/offline_storage.dart';

import '../../utils/helpers.dart';
import '../../utils/http.dart';

import '../../model/config.dart';

import '../../views/base_viewmodel.dart';

class SavedCredentials {
  String serverURL;
  String usr;
  String pwd;

  SavedCredentials({
    this.serverURL = "",
    this.usr = "",
    this.pwd = "",
  });
}

@lazySingleton
class LoginViewModel extends BaseViewModel {
  var savedCreds = SavedCredentials();

  String loginButtonLabel;

  init() {
    loginButtonLabel = "Login";
    var savedUsr = OfflineStorage.getItem('usr');
    var savedPwd = OfflineStorage.getItem('pwd');
    var serverURL = Config().baseUrl;
    savedUsr = savedUsr["data"];
    savedPwd = savedPwd["data"];

    savedCreds = SavedCredentials(
      serverURL: serverURL,
      usr: savedUsr,
      pwd: savedPwd,
    );
  }

  updateConfig(response) {
    Config.set('isLoggedIn', true);

    Config.set(
      'userId',
      response.userId,
    );
    Config.set(
      'user',
      response.fullName,
    );
  }

  cacheCreds(data) {
    OfflineStorage.putItem(
      'usr',
      data["usr"].trimRight(),
    );
    OfflineStorage.putItem(
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
      await initAwesomeItems();

      loginButtonLabel = "Success";
      notifyListeners();

      return {
        "success": true,
        "message": "Success",
      };
    } catch (e) {
      Config.set('isLoggedIn', false);
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
