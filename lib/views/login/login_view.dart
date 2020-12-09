import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'login_viewmodel.dart';

import '../../config/palette.dart';
import '../../widgets/frappe_button.dart';

import '../../app/router.gr.dart';
import '../../app/locator.dart';

import '../../services/navigation_service.dart';

import '../../utils/frappe_alert.dart';
import '../../utils/config_helper.dart';
import '../../utils/enums.dart';
import '../../utils/helpers.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: LoginViewModel().getData(),
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
                                onPressed: () async {
                                  if (_fbKey.currentState.saveAndValidate()) {
                                    var formValue = _fbKey.currentState.value;

                                    var response = await LoginViewModel().login(
                                      formValue,
                                    );

                                    if (response["success"] == true) {
                                      FrappeAlert.successAlert(
                                        title: 'Success',
                                        context: context,
                                      );
                                      locator<NavigationService>()
                                          .pushReplacement(
                                        Routes.home,
                                      );
                                    } else {
                                      if (response["statusCode"] ==
                                          HttpStatus.unauthorized) {
                                        FrappeAlert.errorAlert(
                                          title: "Not Authorized",
                                          subtitle:
                                              'Invalid Username or Password',
                                          context: context,
                                        );
                                      } else {
                                        FrappeAlert.errorAlert(
                                          title: "Error",
                                          subtitle: response["message"],
                                          context: context,
                                        );
                                      }
                                    }
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
