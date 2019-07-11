import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:jenkins_tool/api/constants.dart';
import 'package:jenkins_tool/api/http.dart';
import 'package:jenkins_tool/model/hisotry_resp.dart';
import 'package:jenkins_tool/page/progress_dialog.dart';
import 'package:jenkins_tool/page/space_header.dart';
import 'package:jenkins_tool/util/app_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HistoryPage extends StatefulWidget {
  final String projectName;

  HistoryPage({this.projectName});

  @override
  _HistoryPageState createState() {
    return _HistoryPageState();
  }
}

class _HistoryPageState extends State<HistoryPage> {
  static const String apkName = 'jenkins.apk';
  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ProgressDialog _progressDialog;
  CancelToken _downloadToken;

  List<HistoryBean> projectList = [];
  Map<String, String> taskMap = {};

  @override
  void initState() {
    super.initState();
    _progressDialog = ProgressDialog(context, () {
      _downloadToken.cancel();
      _progressDialog.hide();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('历史记录'),
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
              _getHistoryList(widget.projectName);
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

  Widget _createList(int index) {
    HistoryBean value = projectList.elementAt(index);
    Widget card = new Card(
      child: new Padding(
        padding: EdgeInsets.all(10),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(
              '名称: ${value.name}',
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            new Padding(
              padding: EdgeInsets.only(top: 10),
              child: new Text(
                '打包时间: ${value.buildTime}',
                textAlign: TextAlign.left,
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
                ],
              ),
            )
          ],
        ),
      ),
    );
    return card;
  }

  void _showToast(BuildContext context, String content) {
    final snackBar = SnackBar(
      content: Text(content),
      duration: Duration(milliseconds: 1500),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  /// 获取历史列表
  void _getHistoryList(String projectName) async {
    Response<Map<String, dynamic>> response = await dio
        .get<Map<String, dynamic>>(Constants.historyList + widget.projectName);
    try {
      var data = HistoryResp.fromJsonMap(response.data);
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

  void _downloadFile(HistoryBean bean) {
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

  void _downloadApk(HistoryBean bean) async {
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
}
