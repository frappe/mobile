import 'package:flutter/material.dart';
import 'package:support_app/routes/issue.dart';

import '../main.dart';


class MyCustomForm extends StatefulWidget {
  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Form', style: TextStyle(color: Theme.of(context).primaryColor),),backgroundColor: Colors.white,),
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
            SizedBox(height: 20.0,),
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
                suffixIcon: IconButton(icon: Icon(
                  _isOn ? Icons.visibility_off : Icons.visibility), onPressed: () {
                    setState(() {
                      _isOn = !_isOn;
                    });
                  })
              ),
              obscureText: _isOn,
            ),
            SizedBox(height: 20.0,),
            RaisedButton(
              padding: EdgeInsets.symmetric(horizontal: 80,),
              color: Color(0xff5364ff),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Logging In')));
                  var response2 = await authenticate(usrTextController.text, pwdTextController.text);
                  print(response2);

                  if (response2.statusCode == 200) {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IssueList(),
                    ));
                  } else {
                    // If the server did not return a 200 OK response,
                    // then throw an exception.
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
