import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/utils/backend_service.dart';

import '../main.dart';
import '../utils/http.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  bool _isOn = true;
  var serverURL;
  var savedUsr;
  var savedPwd;
  BackendService backendService;

  @override
  void initState() {
    super.initState();
    backendService = BackendService(context);
    serverURL = localStorage.getString('serverURL');
    savedUsr = localStorage.getString('usr');
    savedPwd = localStorage.getString('pwd');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                FormBuilder(
                  key: _fbKey,
                  child: Column(
                    children: <Widget>[
                      FormBuilderTextField(
                        attribute: 'serverURL',
                        initialValue: serverURL,
                        validators: [
                          FormBuilderValidators.required(),
                          FormBuilderValidators.url()
                        ],
                        decoration: InputDecoration(
                          focusColor: Colors.black,
                          labelText: "Server URL",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      FormBuilderTextField(
                        attribute: 'usr',
                        initialValue: savedUsr,
                        validators: [
                          FormBuilderValidators.required(),
                        ],
                        decoration: InputDecoration(
                          focusColor: Colors.black,
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Theme(
                        data: Theme.of(context)
                            .copyWith(primaryColor: Colors.black),
                        child: FormBuilderTextField(
                          maxLines: 1,
                          attribute: 'pwd',
                          initialValue: savedPwd,
                          validators: [
                            FormBuilderValidators.required(),
                          ],
                          decoration: InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                  icon: Icon(_isOn
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () {
                                    setState(() {
                                      _isOn = !_isOn;
                                    });
                                  })),
                          obscureText: _isOn,
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      RaisedButton(
                        padding: EdgeInsets.symmetric(
                          horizontal: 80,
                        ),
                        color: Colors.blueAccent,
                        onPressed: () async {
                          if (_fbKey.currentState.saveAndValidate()) {
                            var formValue = _fbKey.currentState.value;

                            await setBaseUrl(formValue["serverURL"]);

                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Logging In'),
                              ),
                            );

                            var response2 = await backendService.login(
                                formValue["usr"].trimRight(), formValue["pwd"]);

                            if (response2.statusCode == 200) {
                              localStorage.setBool('isLoggedIn', true);

                              cookies = await getCookies();

                              var userId = response2
                                  .headers.map["set-cookie"][3]
                                  .split(';')[0]
                                  .split('=')[1];
                              localStorage.setString('userId', userId);
                              localStorage.setString(
                                  'user', response2.data["full_name"]);
                              localStorage.setString(
                                'usr',
                                formValue["usr"].trimRight(),
                              );
                              localStorage.setString(
                                'pwd',
                                formValue["pwd"],
                              );

                              await cacheAllUsers(context);
                              Navigator.of(context)
                                  .pushReplacementNamed('/modules');
                            } else {
                              localStorage.setBool('isLoggedIn', false);

                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Login Failed'),
                              ));
                            }
                          }
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
  }
}
