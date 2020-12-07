import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/app/router.gr.dart';
import 'package:frappe_app/services/navigation_service.dart';

import '../app/locator.dart';
import '../services/api/api.dart';
import '../config/palette.dart';
import '../widgets/frappe_button.dart';

import '../utils/frappe_alert.dart';
import '../utils/cache_helper.dart';
import '../utils/config_helper.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';
import '../utils/http.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  var serverURL;

  @override
  void initState() {
    super.initState();
    serverURL = ConfigHelper().baseUrl;
  }

  _getData() async {
    var savedUsr = CacheHelper.getCache('usr');
    var savedPwd = CacheHelper.getCache('pwd');
    savedUsr = savedUsr["data"];
    savedPwd = savedPwd["data"];
    return Future.value({
      "savedUsr": savedUsr,
      "savedPwd": savedPwd,
    });
  }

  _authenticate(data) async {
    await setBaseUrl(data["serverURL"]);

    try {
      var response = await locator<Api>().login(
        data["usr"].trimRight(),
        data["pwd"],
      );

      ConfigHelper.set('isLoggedIn', true);

      FrappeAlert.successAlert(
        title: 'Success',
        context: context,
      );

      ConfigHelper.set(
        'userId',
        response.userId,
      );
      ConfigHelper.set(
        'user',
        response.fullName,
      );
      CacheHelper.putCache(
        'usr',
        data["usr"].trimRight(),
      );
      CacheHelper.putCache(
        'pwd',
        data["pwd"],
      );

      await cacheAllUsers();
      locator<NavigationService>().pushReplacement(Routes.home);
    } catch (e) {
      ConfigHelper.set('isLoggedIn', false);
      if (e.statusCode == HttpStatus.unauthorized) {
        FrappeAlert.errorAlert(
            title: "Not Authorized",
            subtitle: 'Invalid Username or Password',
            context: context);
      } else {
        FrappeAlert.errorAlert(
          title: "Error",
          subtitle: e.message,
          context: context,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _getData(),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        FormBuilder(
                          key: _fbKey,
                          child: Column(
                            children: <Widget>[
                              Image(
                                image: AssetImage('assets/frappe_icon.jpg'),
                                width: 60,
                                height: 60,
                              ),
                              SizedBox(
                                height: 24,
                              ),
                              Text(
                                'Login to Frappe',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 24,
                              ),
                              buildDecoratedWidget(
                                FormBuilderTextField(
                                  attribute: 'serverURL',
                                  initialValue: serverURL,
                                  validators: [
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.url()
                                  ],
                                  decoration: Palette.formFieldDecoration(
                                    true,
                                    "Server URL",
                                  ),
                                ),
                                true,
                                "Server URL",
                              ),
                              buildDecoratedWidget(
                                  FormBuilderTextField(
                                    attribute: 'usr',
                                    initialValue: snapshot.data["savedUsr"],
                                    validators: [
                                      FormBuilderValidators.required(),
                                    ],
                                    decoration: Palette.formFieldDecoration(
                                      true,
                                      "Email Address",
                                    ),
                                  ),
                                  true,
                                  "Email Address"),
                              PasswordField(
                                savedPassword: snapshot.data["savedPwd"],
                              ),
                              FrappeFlatButton(
                                title: 'Login',
                                fullWidth: true,
                                height: 46,
                                buttonType: ButtonType.primary,
                                onPressed: () {
                                  if (_fbKey.currentState.saveAndValidate()) {
                                    var formValue = _fbKey.currentState.value;
                                    _authenticate(formValue);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final String savedPassword;

  const PasswordField({
    Key key,
    this.savedPassword,
  }) : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidePassword = true;
  @override
  Widget build(BuildContext context) {
    return buildDecoratedWidget(
        FormBuilderTextField(
          maxLines: 1,
          attribute: 'pwd',
          initialValue: widget.savedPassword,
          validators: [
            FormBuilderValidators.required(),
          ],
          obscureText: _hidePassword,
          decoration: Palette.formFieldDecoration(
            true,
            "Password",
            FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Text(_hidePassword ? "Show" : "Hide"),
                onPressed: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                }),
          ),
        ),
        true,
        "Password");
  }
}
