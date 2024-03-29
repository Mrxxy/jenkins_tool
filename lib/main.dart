import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jenkins_tool/api/constants.dart';
import 'package:jenkins_tool/page/history_page.dart';
import 'package:jenkins_tool/page/login_page.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jenkins_tool/page/home_page.dart';
import 'api/http.dart';

void main() async {
  _initDio();
  _isLogin().then((isLogin) {
    runApp(MyApp(isLogin));
  });
}

Future<bool> _isLogin() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool flag = prefs.get(Constants.keyLoginFlag) ?? false;
  return flag;
}

Future _initDio() async {
  var deviceType = "";
  var deviceId = "";
  var deviceName = "";
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    deviceType = "Android";
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    deviceId = androidInfo.androidId;
    deviceName = androidInfo.brand;
  } else {
    deviceType = "iOS";
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    deviceId = iosInfo.identifierForVendor;
    deviceName = iosInfo.model;
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString(Constants.keyToken);

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  Map<String, String> headers = {
    'device-type': deviceType,
    "device-id": deviceId,
    'device-name': deviceName,
    'token': token,
    'app-version': packageInfo.version
  };
  dio.options.headers = headers;
  dio.options.baseUrl = Constants.baseUrl;
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  dio.interceptors
      .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> headers = options.headers;
    headers.addAll({'token': prefs.getString(Constants.keyToken)});
  }));
}

class MyApp extends StatelessWidget {
  final bool loginFlag;

  MyApp(this.loginFlag);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '金螳螂家助手',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 119, 194, 248),
      ),
      home: !loginFlag ? LoginPage() : HomePage(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new HomePage(),
        '/login': (BuildContext context) => new LoginPage(),
        '/history': (BuildContext context) => new HistoryPage(),
      },
    );
  }
}
