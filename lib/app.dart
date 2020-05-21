import 'package:flutter/material.dart';

import './pages/login.dart';
import './routes/issue.dart';
import './main.dart';

class FrappeApp extends StatefulWidget {
  @override
  _FrappeAppState createState() => _FrappeAppState();
}

class _FrappeAppState extends State<FrappeApp> {
  bool _isLoggedIn = false;
  bool _isLoaded = false;

  @override
  void initState() {
    _checkIfLoggedIn();
    super.initState();
  }

  void _checkIfLoggedIn() {
    if (localStorage.containsKey('isLoggedIn')) {
      bool loggedIn = localStorage.getBool('isLoggedIn');
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }
    _isLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Support App',
      theme: new ThemeData(
        primaryColor: Colors.black,
        accentColor: Colors.black54,
      ),
      home: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
            body: _isLoaded ? _isLoggedIn ? IssueList() : Login() : Center(child: CircularProgressIndicator())),
            // body: Login()),
      ),
      routes: <String, WidgetBuilder>{
        // Set routes for using the Navigator.
        '/issue': (BuildContext context) => IssueList(),
        '/login': (BuildContext context) => Login()
      },
    );
  }
}
