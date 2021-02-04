import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

import '../../app/locator.dart';
import '../../services/api/api.dart';
import '../../model/offline_storage.dart';
import '../../utils/config_helper.dart';
import '../../utils/http.dart';

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
    var serverURL = ConfigHelper().baseUrl;
    savedUsr = savedUsr["data"];
    savedPwd = savedPwd["data"];

    savedCreds = SavedCredentials(
      serverURL: serverURL,
      usr: savedUsr,
      pwd: savedPwd,
    );
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
