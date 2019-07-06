import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {
  /// 请求权限
  static Future<bool> checkPermission(PermissionGroup permissionGroup) async {
    if (Platform.isAndroid) {
      PermissionStatus permission =
          await PermissionHandler().checkPermissionStatus(permissionGroup);
      if (permission != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler().requestPermissions([permissionGroup]);
        if (permissions[permissionGroup] == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  static void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

}
