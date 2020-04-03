
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'utils/http.dart';
import 'routes/IssueList.dart';

void main() async {
  runApp(MyApp());
  var cookieJar = await cookie();
  dio.interceptors.add(CookieManager(cookieJar));
}

Future authenticate(usr, pwd) async {
  final response =
      await dio.post('/method/login', data: {'usr': usr, 'pwd': pwd});

  print(response);
  return response;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(primaryColor: Color.fromRGBO(58, 66, 86, 1.0)),
      home: Scaffold(
        appBar: AppBar(title: Text('Form')),
        body: MyCustomForm(),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();
  bool isOn = false;

  final usrTextController = TextEditingController();
  final pwdTextController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usrTextController.dispose();
    pwdTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
            decoration: const InputDecoration(hintText: "Email"),
          ),
          Row(
            children: <Widget>[
              Flexible(
                child: TextFormField(
                  controller: pwdTextController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'please enter password';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(hintText: "Password"),
                  obscureText: !isOn,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Checkbox(
                value: isOn,
                onChanged: (value) {
                  setState(() {
                    isOn = value;
                  });
                },
              )
            ],
          ),
          RaisedButton(
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Logging In')));
                var response2 = await authenticate(usrTextController.text, pwdTextController.text);

                if (response2.statusCode == 200) {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IssueList({}),
                  ));
                } else {
                  // If the server did not return a 200 OK response,
                  // then throw an exception.
                  throw Exception('Failed to load album');
                }
              }
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}
