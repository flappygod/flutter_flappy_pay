import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_flappy_pay/flutter_flappy_pay.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  String payStr='{ "miniuser":"gh_744d2ebca056", "package":"Sign=WXPay","minipath":"pages/appPay/index","appid":"wxde49e54377b35da9","sign":"9A79D0E181D8B01466CD788188A5BCBA","partnerid":"396595359","prepayid":"bafd102aa6ba407fbbfe400480eb57c4","noncestr":"WRKcvxwpmtRDHikHEyjwjDIYGwWpViBO","timestamp":"20201119112459"}';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      //platformVersion = await FlutterFlappyPay.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            Map  dataStr=await FlutterFlappyPay.yunPay(payStr,  YunPayType.TYPE_WX);
            print(dataStr);
          },
          child: Center(
            child: Text('Running on: $_platformVersion\n'),
          ),
        ),
      ),
    );
  }
}
