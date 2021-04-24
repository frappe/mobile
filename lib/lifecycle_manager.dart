import 'package:flutter/material.dart';
import 'package:frappe_app/services/storage_service.dart';
import 'package:frappe_app/utils/helpers.dart';

import 'app/locator.dart';

class LifeCycleManager extends StatefulWidget {
  final Widget child;
  LifeCycleManager({required this.child});

  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        print('detached');
        await locator<StorageService>().putSharedPrefBoolValue(
          "backgroundTask",
          true,
        );
        break;
      case AppLifecycleState.resumed:
        await locator<StorageService>().putSharedPrefBoolValue(
          "backgroundTask",
          false,
        );
        print('resume...');
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }
}
