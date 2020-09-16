import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/screens/custom_persistent_bottom_nav_bar.dart';

import '../main.dart';
import '../config/palette.dart';
import '../utils/backend_service.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';
import '../utils/http.dart';
import '../widgets/frappe_button.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  bool _hidePassword = true;
  var serverURL;
  var savedUsr;
  var savedPwd;
  BackendService backendService;

  @override
  void initState() {
    super.initState();
    backendService = BackendService();
    serverURL = localStorage.getString('serverURL');
    savedUsr = localStorage.getString('usr');
    savedPwd = localStorage.getString('pwd');
  }

  _authenticate(data) async {
    await setBaseUrl(data["serverURL"]);

    // Scaffold.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('Logging In'),
    //   ),
    // );

    var response2 =
        await backendService.login(data["usr"].trimRight(), data["pwd"]);

    if (response2.statusCode == 200) {
      localStorage.setBool('isLoggedIn', true);

      cookies = await getCookies();

      var userId =
          response2.headers.map["set-cookie"][3].split(';')[0].split('=')[1];
      localStorage.setString('userId', userId);
      localStorage.setString('user', response2.data["full_name"]);
      localStorage.setString(
        'usr',
        data["usr"].trimRight(),
      );
      localStorage.setString(
        'pwd',
        data["pwd"],
      );
      primaryCacheKey = "$baseUrl$userId";
      localStorage.setString('primaryCacheKey', primaryCacheKey);

      await cacheAllUsers(context);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) {
          return CustomPersistentBottomNavBar();
        },
      ));
      // pushNewScreen(
      //   context,
      //   screen: BottomBar(),
      // );
    } else {
      localStorage.setBool('isLoggedIn', false);

      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Login Failed'),
      ));
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
      body: SingleChildScrollView(
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
                              initialValue: savedUsr,
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
                        buildDecoratedWidget(
                            FormBuilderTextField(
                              maxLines: 1,
                              attribute: 'pwd',
                              initialValue: savedPwd,
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
                                    child:
                                        Text(_hidePassword ? "Show" : "Hide"),
                                    onPressed: () {
                                      setState(() {
                                        _hidePassword = !_hidePassword;
                                      });
                                    }),
                              ),
                            ),
                            true,
                            "Password"),
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
      ),
    );
  }
}
