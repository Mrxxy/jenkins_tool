import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jenkins_tool/model/check_update_resp.dart';
import 'package:jenkins_tool/page/history_page.dart';
import 'package:jenkins_tool/page/progress_dialog.dart';
import 'package:jenkins_tool/page/space_header.dart';
import 'package:jenkins_tool/util/app_utils.dart';
import 'package:jenkins_tool/api/constants.dart';
import 'package:jenkins_tool/api/http.dart';
import 'package:jenkins_tool/model/build_resp.dart';
import 'package:jenkins_tool/model/jenkins_list_resp.dart';
import 'package:jenkins_tool/model/project_bean.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  static const String apkName = 'jenkins.apk';
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();
  List<ProjectBean> projectList = [];
  ProgressDialog _progressDialog;
  CancelToken _downloadToken;

  @override
  void initState() {
    super.initState();
    _progressDialog = ProgressDialog(context, () {
      _downloadToken.cancel();
      _progressDialog.hide();
    });
  }

  void _checkUpdate() async {
    Response<Map<String, dynamic>> response =
        await dio.get<Map<String, dynamic>>(Constants.updateUrl);
    try {
      var data = CheckUpdateResp.fromJsonMap(response.data);
      var flag = data.data.updateFlag;
      if (flag == 10086) {
        _showAlertDialog(context, data.data.desc, data.data.url);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  /// 获取jenkins任务列表
  void _getJenkinsList() async {
    Response<Map<String, dynamic>> response =
        await dio.get<Map<String, dynamic>>(Constants.jenkinsList);
    try {
      var data = JenkinsListResp.fromJsonMap(response.data);
      var result = data.meta.errorCode;
      if (result == 1000) {
        setState(() {
          projectList = data.data;
        });
      } else {
        _showToast(context, data.meta.errorMsg);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(Constants.keyToken, '');
        prefs.setBool(Constants.keyLoginFlag, false);
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  /// 打包
  void _buildProject(String name) async {
    Response<Map<String, dynamic>> response =
        await dio.get<Map<String, dynamic>>(Constants.jenkinsBuild + name);
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
    _downloadToken = new CancelToken();
    final savedDir =
        (await getExternalStorageDirectory()).path + '/GoldmantisHome';
    final dir = Directory(savedDir);
    bool hasExisted = await dir.exists();
    if (!hasExisted) {
      dir.create();
    }
    var filePath = savedDir + "/" + apkName;
    if (!_progressDialog.isShowing()) {
      _progressDialog.show();
    }
    await dio.download(bean.pacUrl, filePath, cancelToken: _downloadToken,
        onProgress: (received, total) {
      var progress = received / total;
      _progressDialog.update(progress);
      if (received == total) {
        _progressDialog.hide();
        InstallPlugin.installApk(filePath, 'com.goldmantis.app.jenkins_tool');
      }
    });
  }

  Widget _createList(int index) {
    ProjectBean value = projectList.elementAt(index);
    Widget card = GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HistoryPage(
                      projectName: value.name,
                    )));
      },
      child: new Card(
        child: new Padding(
          padding: EdgeInsets.all(10),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  new Text(
                    '名称: ${value.fullName}',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text('状态:'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Icon(
                      Icons.brightness_1,
                      size: 18,
                      color: value.currentBuildNumber == value.lastSuccessNumber
                          ? Color.fromARGB(255, 70, 119, 177)
                          : Colors.red,
                    ),
                  )
                ],
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
                    value.build
                        ? new Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: OutlineButton(
                              child: new Text(
                                '打包',
                                style: TextStyle(fontSize: 13),
                              ),
                              shape: new RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 189, 162, 39)),
                              textColor: Colors.black,
                              onPressed: () {
                                _buildProject(value.name);
                              },
                            ),
                          )
                        : new Text('')
                  ],
                ),
              )
            ],
          ),
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
          title: Text(
            '金螳螂家助手',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.swap_horiz,
                color: Colors.white,
              ),
              tooltip: '注销',
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('提示'),
                        content: Text('确认退出当前账号？'),
                        actions: <Widget>[
                          new FlatButton(
                            onPressed: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setString(Constants.keyToken, '');
                              prefs.setBool(Constants.keyLoginFlag, false);
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/login', (Route<dynamic> route) => false);
                            },
                            child: new Text(
                              "确认",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          new FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop("");
                            },
                            child: new Text("取消"),
                          ),
                        ],
                      );
                    });
              },
            )
          ],
        ),
        body: Center(
          child: EasyRefresh(
            key: _easyRefreshKey,
            firstRefresh: true,
            autoLoad: false,
            behavior: ScrollOverBehavior(),
            refreshHeader: SpaceHeader(
              key: _headerKey,
            ),
            onRefresh: () async {
              _getJenkinsList();
              _checkUpdate();
            },
            child: ListView.builder(
              itemCount: projectList.length,
              itemBuilder: (BuildContext context, int position) {
                return _createList(position);
              },
            ),
          ),
        ));
  }

  void _showAlertDialog(BuildContext context, String desc, String url) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
                title: new Text("更新提示"),
                content: new Text(desc),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text("取消"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  new FlatButton(
                    child: new Text("下载"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      AppUtils.launchURL(url);
                    },
                  )
                ]));
  }

  void _showToast(BuildContext context, String content) {
    final snackBar = SnackBar(
      content: Text(content),
      duration: Duration(milliseconds: 1500),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
