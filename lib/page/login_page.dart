import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jenkins_tool/page/home_page.dart';
import 'package:jenkins_tool/api/constants.dart';
import 'package:jenkins_tool/api/http.dart';
import 'package:jenkins_tool/model/login_resp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _accountController = TextEditingController();
  GlobalKey _accountKey = new GlobalKey<FormFieldState>();
  TextEditingController _pwdController = TextEditingController();
  GlobalKey _pwdKey = new GlobalKey<FormFieldState>();
  bool _hidePwd = true;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Center(
              child: new Text(
            '登录',
            textAlign: TextAlign.center,
          )),
        ),
        body: new SingleChildScrollView(
            child: new Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40),
              child: Image(
                image: AssetImage('assets/images/login_logo.png'),
                width: 80,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 30),
              child: TextFormField(
                key: _accountKey,
                decoration: InputDecoration(
                    labelText: '用户名',
                    hintText: '工号或手机号',
                    prefixIcon: Icon(Icons.account_circle)),
                cursorColor: Colors.black54,
                controller: _accountController,
                autovalidate: true,
                autofocus: true,
                validator: (value) {
                  return value.trim().length > 0 ? null : "用户名不能为空";
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: TextFormField(
                key: _pwdKey,
                decoration: InputDecoration(
                    labelText: '密码',
                    hintText: 'ERP密码',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.remove_red_eye,
                      ),
                      onPressed: () {
                        setState(() {
                          _hidePwd = !_hidePwd;
                        });
                      },
                    )),
                obscureText: _hidePwd,
                cursorColor: Colors.black54,
                controller: _pwdController,
                autovalidate: true,
                validator: (value) {
                  return value.trim().length > 0 ? null : "密码不能为空";
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: SizedBox(
                  height: 45,
                  width: double.infinity,
                  child: RaisedButton(
                    color: Color.fromARGB(255, 61, 168, 245),
                    child: Text(
                      '登录',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onPressed: () {
                      if ((_accountKey.currentState as FormFieldState)
                              .validate() &&
                          (_pwdKey.currentState as FormFieldState).validate()) {
                        _login(_accountController.text, _pwdController.text);
                      }
                    },
                  )),
            ),
          ],
        )));
  }

  void showToast(BuildContext context, String content) {
    final snackBar = SnackBar(
      content: Text(content),
      duration: Duration(milliseconds: 1500),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void _login(String account, String pwd) async {
    var formData = new FormData.from({'account': account, 'pwd': pwd});
    Response<Map<String, dynamic>> response = await dio
        .post<Map<String, dynamic>>(Constants.loginUrl, data: formData);
    try {
      var data = LoginResp.fromJsonMap(response.data);
      var result = data.meta.errorCode;
      if (result == 1000) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(Constants.keyToken, data.data);
        prefs.setBool(Constants.keyLoginFlag, true);
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      } else {
        showToast(context, '登录失败');
      }
      print(response.data.toString());
    } catch (e) {
      print(e.toString());
      showToast(context, '登录失败');
    }
  }
}
