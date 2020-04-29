import 'package:flutter/material.dart';
import 'package:support_app/pages/custom_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support_app/routes/issue.dart';


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _isLoaded = false;

  @override
  void initState() {
    _checkIfLoggedIn();
    super.initState();
  }

  void _checkIfLoggedIn() async{
      // check if token is there
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      bool loggedIn = localStorage.getBool('isLoggedIn');
      if(loggedIn){
         setState(() {
            _isLoggedIn = true;
         });
      }
      _isLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: new ThemeData(primaryColor: Color.fromRGBO(58, 66, 86, 1.0)),
      // theme: new ThemeData(primaryColor: Colors.white),
      home: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
              child: Scaffold(
          // appBar: AppBar(title: Text('Form', style: TextStyle(color: Theme.of(context).primaryColor),),backgroundColor: Colors.white,),
          body: _isLoaded ? _isLoggedIn ? IssueList() : MyCustomForm() : Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: new ThemeData(primaryColor: Color.fromRGBO(58, 66, 86, 1.0)),
//       // theme: new ThemeData(primaryColor: Colors.white),
//       home: GestureDetector(
//         onTap: () {
//           FocusScope.of(context).requestFocus(new FocusNode());
//         },
//               child: Scaffold(
//           appBar: AppBar(title: Text('Form', style: TextStyle(color: Theme.of(context).primaryColor),),backgroundColor: Colors.white,),
//           body: MyCustomForm(),
//         ),
//       ),
//     );
//   }
// }