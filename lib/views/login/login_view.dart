import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'login_viewmodel.dart';

import '../../config/palette.dart';
import '../../widgets/frappe_button.dart';

import '../../app/router.gr.dart';
import '../../app/locator.dart';

import '../../views/base_view.dart';
import '../../services/navigation_service.dart';

import '../../utils/frappe_alert.dart';
import '../../utils/enums.dart';
import '../../utils/helpers.dart';

class Login extends StatelessWidget {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return BaseView<LoginViewModel>(
      onModelReady: (model) {
        model.init();
      },
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 60,
              ),
              FrappeLogo(),
              SizedBox(
                height: 24,
              ),
              Title(),
              SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    FormBuilder(
                      key: _fbKey,
                      child: Column(
                        children: <Widget>[
                          buildDecoratedWidget(
                            FormBuilderTextField(
                              name: 'serverURL',
                              initialValue: model.savedCreds.serverURL,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(context),
                                FormBuilderValidators.url(context),
                              ]),
                              decoration: Palette.formFieldDecoration(
                                withLabel: true,
                                label: "Server URL",
                              ),
                            ),
                            true,
                            "Server URL",
                          ),
                          buildDecoratedWidget(
                              FormBuilderTextField(
                                name: 'usr',
                                initialValue: model.savedCreds.usr,
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(context),
                                ]),
                                decoration: Palette.formFieldDecoration(
                                  withLabel: true,
                                  label: "Email Address",
                                ),
                              ),
                              true,
                              "Email Address"),
                          PasswordField(
                            savedPassword: model.savedCreds.pwd,
                          ),
                          FrappeFlatButton(
                            title: model.loginButtonLabel,
                            fullWidth: true,
                            height: 46,
                            buttonType: ButtonType.primary,
                            onPressed: () async {
                              FocusScope.of(context).requestFocus(
                                FocusNode(),
                              );

                              if (_fbKey.currentState.saveAndValidate()) {
                                var formValue = _fbKey.currentState.value;

                                var response = await model.login(
                                  formValue,
                                );

                                if (response["success"] == true) {
                                  locator<NavigationService>().pushReplacement(
                                    Routes.deskView,
                                  );
                                } else {
                                  if (response["statusCode"] ==
                                      HttpStatus.unauthorized) {
                                    FrappeAlert.errorAlert(
                                      title: "Not Authorized",
                                      subtitle: 'Invalid Username or Password',
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
        ),
      ),
    );
  }
}

class Title extends StatelessWidget {
  const Title({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Login to Frappe',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class FrappeLogo extends StatelessWidget {
  const FrappeLogo({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage('assets/frappe_icon.jpg'),
      width: 60,
      height: 60,
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
          name: 'pwd',
          initialValue: widget.savedPassword,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(context),
          ]),
          obscureText: _hidePassword,
          decoration: Palette.formFieldDecoration(
            withLabel: true,
            label: "Password",
            suffixIcon: FlatButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Text(_hidePassword ? "Show" : "Hide"),
              onPressed: () {
                setState(
                  () {
                    // TODO
                    _hidePassword = !_hidePassword;
                  },
                );
              },
            ),
          ),
        ),
        true,
        "Password");
  }
}
