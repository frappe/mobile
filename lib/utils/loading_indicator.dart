import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoadingIndicator {
  static loadingWithBackgroundDisabled([String? message = "Loading"]) {
    EasyLoading.show(
      status: '$message...',
      maskType: EasyLoadingMaskType.black,
      indicator: CircularProgressIndicator(
        backgroundColor: Colors.white,
      ),
    );
  }

  static stopLoading() {
    EasyLoading.dismiss();
  }
}
