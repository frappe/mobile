import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/form/controls/control.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/utils/navigation_helper.dart';
import 'package:frappe_app/views/home_view.dart';

import 'login_viewmodel.dart';

import '../../config/palette.dart';
import '../../widgets/frappe_button.dart';

import '../../views/base_view.dart';

import '../../utils/frappe_alert.dart';
import '../../utils/enums.dart';

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
                          buildDecoratedControl(
                            control: FormBuilderTextField(
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
                            withLabel: true,
                            label: "Server URL",
                          ),
                          buildDecoratedControl(
                            control: FormBuilderTextField(
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
                            withLabel: true,
                            label: "Email Address",
                          ),
                          PasswordField(),
                          FrappeFlatButton(
                            title: model.loginButtonLabel,
                            fullWidth: true,
                            height: 46,
                            buttonType: ButtonType.primary,
                            onPressed: () async {
                              FocusScope.of(context).requestFocus(
                                FocusNode(),
                              );

                              if (_fbKey.currentState != null) {
                                if (_fbKey.currentState!.saveAndValidate()) {
                                  var formValue = _fbKey.currentState?.value;

                                  try {
                                    await model.login(
                                      formValue,
                                    );

                                    NavigationHelper.pushReplacement(
                                      context: context,
                                      page: HomeView(),
                                    );
                                  } catch (e) {
                                    var _e = e as ErrorResponse;

                                    if (_e.statusCode ==
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
                                        subtitle: _e.statusMessage,
                                        context: context,
                                      );
                                    }
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
  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return buildDecoratedControl(
      control: Stack(
        alignment: Alignment.centerRight,
        children: [
          FormBuilderTextField(
            maxLines: 1,
            name: 'pwd',
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(context),
            ]),
            obscureText: _hidePassword,
            decoration: Palette.formFieldDecoration(
              withLabel: true,
              label: "Password",
            ),
          ),
          TextButton(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(
                Colors.transparent,
              ),
            ),
            child: Text(
              _hidePassword ? "Show" : "Hide",
              style: TextStyle(
                color: FrappePalette.grey[600],
              ),
            ),
            onPressed: () {
              setState(
                () {
                  _hidePassword = !_hidePassword;
                },
              );
            },
          )
        ],
      ),
      withLabel: true,
      label: "Password",
    );
  }
}
