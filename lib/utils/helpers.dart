import 'package:flutter/material.dart';

import '../main.dart';
import 'http.dart';

logout(context) async {
  var cookieJar = await cookie();
  cookieJar.delete(Uri(
      scheme: "http",
      port: int.parse("8000", radix: 16),
      host: "erpnext.dev2"));

    Navigator.push(
      context,
        MaterialPageRoute(
          builder: (context) => MyApp(),
        ));
}
