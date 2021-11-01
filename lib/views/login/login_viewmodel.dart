import 'package:frappe_app/model/login_request.dart';
import 'package:frappe_app/model/login_response.dart';
import 'package:frappe_app/utils/dio_helper.dart';
import 'package:injectable/injectable.dart';

import '../../app/locator.dart';
import '../../services/api/api.dart';
import '../../model/offline_storage.dart';

import '../../utils/helpers.dart';
import '../../utils/http.dart';

import '../../model/config.dart';

import '../../views/base_viewmodel.dart';

class SavedCredentials {
  String? serverURL;
  String? usr;

  SavedCredentials({
    this.serverURL,
    this.usr,
  });
}

@lazySingleton
class LoginViewModel extends BaseViewModel {
  var savedCreds = SavedCredentials();

  late String loginButtonLabel;

  init() {
    loginButtonLabel = "Login";

    savedCreds = SavedCredentials(
      serverURL: Config().baseUrl,
      usr: OfflineStorage.getItem('usr')["data"],
    );
  }

  updateUserDetails(LoginResponse response) {
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

  getSystemSettings() async {
    var systemSettings = await locator<Api>().getSystemSettings();
    // TODO: check permission
    OfflineStorage.putItem(
      'systemSettings',
      systemSettings.toJson(),
    );
  }

  Future<LoginResponse> login(LoginRequest loginRequest) async {
    loginButtonLabel = "Verifying...";
    notifyListeners();

    try {
      var response = await locator<Api>().login(
        loginRequest,
      );

      if (response.verification != null) {
        loginButtonLabel = "Verify";
        return response;
      } else {
        updateUserDetails(response);

        OfflineStorage.putItem(
          'usr',
          loginRequest.usr,
        );

        await cacheAllUsers();
        await initAwesomeItems();
        await DioHelper.initCookies();
        getSystemSettings();

        loginButtonLabel = "Success";
        notifyListeners();

        return response;
      }
    } catch (e) {
      Config.set('isLoggedIn', false);
      loginButtonLabel = "Login";
      notifyListeners();
      throw e;
    }
  }
}
