import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jenkins_tool/util/AppUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'api/Api.dart';
import 'model/BuildResp.dart';
import 'model/JenkinsListResp.dart';
import 'model/ProjectBean.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:install_plugin/install_plugin.dart';

class HomePage extends StatefulWidget {
  final String title;

  HomePage({Key key, this.title}) : super(key: key);

  @override
  _HomePageState createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  static const String apkName = 'jenkins.apk';
  Map<String, String> taskMap = {};
  List<ProjectBean> projectList = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    FlutterDownloader.registerCallback((id, status, progress) {
      print('progress : $progress');
      if (status == DownloadTaskStatus.complete) {
        InstallPlugin.installApk(
            '${taskMap[id]}/$apkName', 'com.goldmantis.app.jenkins_tool');
      }
    });
    _getJenkinsList();
  }

  @override
  void dispose() {
    FlutterDownloader.registerCallback(null);
    super.dispose();
  }

  /// 获取jenkins任务列表
  void _getJenkinsList() async {
    Dio dio = new Dio();
    var deviceType = "";
    if (Platform.isAndroid) {
      deviceType = "Android";
    } else {
      deviceType = "iOS";
    }
    Map<String, String> headers = {'device-type': deviceType};
    dio.options.headers = headers;
    Response<Map<String, dynamic>> response =
        await dio.get<Map<String, dynamic>>(Api.jenkinsList);
    try {
      var data = JenkinsListResp.fromJsonMap(response.data);
      var result = data.meta.errorCode;
      if (result == 1000) {
        setState(() {
          projectList = data.data;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  /// 打包
  void _buildProject(String name) async {
    print('build: $name');
    Dio dio = new Dio();
    var deviceType = "";
    if (Platform.isAndroid) {
      deviceType = "Android";
    } else {
      deviceType = "iOS";
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String device = prefs.getString('device');
    if (device == null || device.isEmpty) {
      device = Uuid().v4().toString();
      await prefs.setString('device', device);
    }

    Map<String, String> headers = {'device-type': deviceType, "device": device};
    dio.options.headers = headers;
    Response<Map<String, dynamic>> response =
        await dio.get<Map<String, dynamic>>(Api.jenkinsBuild + name);
    try {
      var data = BuildResp.fromJsonMap(response.data);
      var result = data.meta.errorCode;
      if (result == 1000) {
        _showToast(context, '打包中，请稍后...');
      } else {
        _showToast(context, '打包失败，请重试');
      }
    } catch (e) {
      print(e.toString());
      _showToast(context, '打包失败，请重试');
    }
  }

  void _downloadFile(ProjectBean bean) {
    if (Platform.isAndroid) {
      AppUtils.checkPermission(PermissionGroup.storage).then((hasGranted) {
        if (hasGranted) {
          _downloadApk(bean);
        } else {
          _showToast(context, '授权失败，请前往设置-权限管理中打开权限');
        }
      });
    } else {
      AppUtils.launchURL(bean.pacUrl);
    }
  }

  void _downloadApk(ProjectBean bean) async {
    final savedDir = (await getExternalStorageDirectory()).path + '/download';
    final dir = Directory(savedDir);
    bool hasExisted = await dir.exists();
    if (!hasExisted) {
      dir.create();
    }
    String taskId = await FlutterDownloader.enqueue(
        url: bean.pacUrl,
        fileName: apkName,
        savedDir: savedDir,
        showNotification: true,
        openFileFromNotification: false);
    taskMap.addAll({taskId: savedDir});
  }

  Widget _createList(int index) {
    ProjectBean value = projectList.elementAt(index);
    print('download url is ${value.pacUrl}');
    Widget card = new Card(
      child: new Padding(
        padding: EdgeInsets.all(10),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(
              '名称: ${value.fullName}',
              textAlign: TextAlign.left,
            ),
            new Padding(
              padding: EdgeInsets.only(top: 10),
              child: new Text(
                '上次打包时间: ${value.currentBuildTime}',
                textAlign: TextAlign.left,
              ),
            ),
            new Padding(
              padding: EdgeInsets.only(top: 10),
              child: new Row(
                children: <Widget>[
                  new Text('上次成功: ${value.lastSuccessNumber}'),
                  new Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: new Text('当前build: ${value.currentBuildNumber}'),
                  )
                ],
              ),
            ),
            new Padding(
              padding: EdgeInsets.only(top: 10),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  OutlineButton(
                    child: new Text(
                      '安装',
                      style: TextStyle(fontSize: 13),
                    ),
                    shape: new RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 189, 162, 39)),
                    textColor: Colors.black,
                    onPressed: () {
                      _downloadFile(value);
                    },
                  ),
                  new Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: OutlineButton(
                      child: new Text(
                        '打包',
                        style: TextStyle(fontSize: 13),
                      ),
                      shape: new RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 189, 162, 39)),
                      textColor: Colors.black,
                      onPressed: () {
                        _buildProject(value.name);
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
    return card;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            new IconButton(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
                textDirection: TextDirection.ltr,
                size: 30,
              ),
              onPressed: () {
                _getJenkinsList();
              },
            )
          ],
        ),
        body: ListView.builder(
          itemCount: projectList.length,
          itemBuilder: (BuildContext context, int position) {
            return _createList(position);
          },
        ));
  }

  void _showToast(BuildContext context, String content) {
    final snackBar = SnackBar(
      content: Text(content),
      duration: Duration(milliseconds: 1500),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
