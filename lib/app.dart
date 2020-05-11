import 'package:flutter/material.dart';
import 'package:support_app/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support_app/routes/issue.dart';


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _isLoaded = false;
  // Widget _defaultHome = MyCustomForm();

  @override
  void initState() {
    _checkIfLoggedIn();
    super.initState();
  }

  void _checkIfLoggedIn() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if (localStorage.containsKey('isLoggedIn')) {
      print('in local storage');
      // if (localStorage.getBool('isLoggedIn')==true) {
      //   print('set issue route');
      //   _defaultHome = IssueList();
      // }
      bool loggedIn = localStorage.getBool('isLoggedIn');
      print('got value logged in');
      print('reached set state');
      setState(() {
        print('setting _is logged in');
        _isLoggedIn = loggedIn;
      });
    }
    // print(_defaultHome);
    print('reached _is loaded');
    _isLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Support App',
      theme: new ThemeData(
        // primaryColor: Color.fromRGBO(58, 66, 86, 1.0),
        primaryColor: Color(0xff5e64ff),
      ),
      // theme: new ThemeData(primaryColor: Colors.white),
      home: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
              child: Scaffold(
          // appBar: AppBar(title: Text('Form', style: TextStyle(color: Theme.of(context).primaryColor),),backgroundColor: Colors.white,),
          body: _isLoaded ? _isLoggedIn ? IssueList() : MyCustomForm() : Center(child: CircularProgressIndicator()),
          // _isLoaded ? _defaultHome : Center(child: CircularProgressIndicator()),
          // _isLoaded ? _isLoggedIn ? IssueList() : MyCustomForm() : Center(child: CircularProgressIndicator()),
        ),
      ),
      routes: <String, WidgetBuilder>{
      // Set routes for using the Navigator.
      '/issue': (BuildContext context) => IssueList(),
      '/login': (BuildContext context) => MyCustomForm()
    },
    );
  }
}