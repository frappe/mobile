import 'package:flutter/material.dart';

class NoInternet extends StatelessWidget {
  final bool hideAppBar;

  const NoInternet([
    this.hideAppBar = false,
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hideAppBar
          ? null
          : AppBar(
              elevation: 0,
            ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Seems like you are not connected to Internet, you need to download module to access data when Offline.',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
