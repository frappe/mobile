import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../services/api/api.dart';

import '../../utils/helpers.dart';
import '../../utils/dio_helper.dart';
import '../../utils/cache_helper.dart';

class DioApi implements Api {
  Future login(String usr, String pwd) async {
    final response = await DioHelper.dio.post(
      '/method/login',
      data: {
        'usr': usr,
        'pwd': pwd,
      },
      options: Options(
        validateStatus: (status) {
          return status < 500;
        },
      ),
    );
    return response;
  }
}
