import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/http.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  static final _formKey = GlobalKey<FormState>();
  bool _isOn = true;

  final TextEditingController usrTextController = new TextEditingController();
  final TextEditingController pwdTextController = new TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usrTextController.dispose();
    pwdTextController.dispose();
    super.dispose();
  }

  Future _authenticate(usr, pwd) async {
    final response =
        await dio.post('/method/login', data: {'usr': usr, 'pwd': pwd});
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.setBool('isLoggedIn', false);
    if (response.statusCode == 200) {
      localStorage.setBool('isLoggedIn', true);
    }
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: usrTextController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'please enter email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          focusColor: Colors.black,
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        controller: pwdTextController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'please enter password';
                          }
                          return null;
                        },
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
                      SizedBox(
                        height: 20.0,
                      ),
                      RaisedButton(
                        padding: EdgeInsets.symmetric(
                          horizontal: 80,
                        ),
                        color: Theme.of(context).primaryColor,
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            Scaffold.of(context).showSnackBar(
                                SnackBar(content: Text('Logging In')));
                            var response2 = await _authenticate(
                                usrTextController.text.trimRight(),
                                pwdTextController.text);
                            print(response2);

                            if (response2.statusCode == 200) {
                              Navigator.of(context)
                                  .pushReplacementNamed('/issue');
                            } else {
                              throw Exception('Failed to load album');
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
