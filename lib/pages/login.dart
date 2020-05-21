import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

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

  Future _authenticate(usr, pwd) async {
    final response =
        await dio.post('/method/login', data: {'usr': usr, 'pwd': pwd});
    localStorage.setBool('isLoggedIn', false);
    if (response.statusCode == 200) {
      localStorage.setBool('isLoggedIn', true);
    }
    return response;
  }

  @override
  void initState() {
    super.initState();
    serverURL = localStorage.getString('serverURL');
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
      body: ListView(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
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
                      FormBuilderTextField(
                        maxLines: 1,
                        attribute: 'pwd',
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
                      SizedBox(
                        height: 20.0,
                      ),
                      RaisedButton(
                        padding: EdgeInsets.symmetric(
                          horizontal: 80,
                        ),
                        color: Theme.of(context).primaryColor,
                        onPressed: () async {
                          if (_fbKey.currentState.saveAndValidate()) {
                            var formValue = _fbKey.currentState.value;

                            await setBaseUrl(formValue["serverURL"]);

                            Scaffold.of(context).showSnackBar(
                                SnackBar(content: Text('Logging In')));
                            var response2 = await _authenticate(
                                formValue["usr"].trimRight(),
                                formValue["pwd"]);
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
