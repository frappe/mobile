import 'package:flutter/material.dart';
import 'package:support_app/pages/custom_form.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: new ThemeData(primaryColor: Color.fromRGBO(58, 66, 86, 1.0)),
      home: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
              child: Scaffold(
          appBar: AppBar(title: Text('Form')),
          body: MyCustomForm(),
        ),
      ),
    );
  }
}