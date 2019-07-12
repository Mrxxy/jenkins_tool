import 'package:flutter/material.dart';

double _progress = 0.0;
bool _isShowing = false;
Function _callback;

class ProgressDialog {
  _Dialog _dialog;
  BuildContext _buildContext, _context;

  ProgressDialog(BuildContext buildContext, Function callback) {
    _buildContext = buildContext;
    _callback = callback;
  }

  bool isShowing() {
    return _isShowing;
  }

  void update(double progress) {
    _progress = progress;
    _dialog.update();
  }

  void hide() {
    if (_isShowing) {
      _isShowing = false;
      Navigator.of(_context).pop();
    }
  }

  void show() {
    if (!_isShowing) {
      _dialog = new _Dialog();
      _isShowing = true;
      showDialog<dynamic>(
        context: _buildContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          _context = context;
          return Dialog(
              insetAnimationCurve: Curves.easeInOut,
              insetAnimationDuration: Duration(milliseconds: 100),
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: _dialog);
        },
      );
    }
  }
}

class _Dialog extends StatefulWidget {
  final _dialog = new _DialogState();

  update() {
    _dialog.changeState();
  }

  @override
  _DialogState createState() {
    return _dialog;
  }
}

class _DialogState extends State<_Dialog> {
  void changeState() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _isShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _callback,
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 15, top: 20, bottom: 10),
              child: Text(
                '下载中,请稍后...',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
              child: LinearProgressIndicator(
                value: _progress,
              ),
            ),
            Padding(
                padding:
                    EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text('${(_progress * 100).toInt()}/100'),
                  ],
                )),
            Padding(
                padding:
                    EdgeInsets.only(top: 10, bottom: 20, left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    GestureDetector(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          '取消',
                          style: TextStyle(
                              color: Color.fromARGB(255, 119, 194, 248),
                              fontSize: 15),
                        ),
                      ),
                      onTap: _callback,
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
