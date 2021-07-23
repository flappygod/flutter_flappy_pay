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

  String payStr =
      "{\n  \"sign\" : \"5D3E48B7801266EE9E1CE2ADC73BC279\",\n  \"partnerid\" : \"396595359\",\n  \"prepayid\" : "
      "\"f7f325f3371a4eaab957fe6844451f10\",\n  \"timestamp\" : \"20201119150209\",\n  \"package\" : \"Sign=WXPay\",\n  \"noncestr\" : \"uKZEBnUDEexIvkISSYzenbrjHkVqOxNp\",\n  \"minipath\" : \"pages\\/appPay\\/index\",\n  \"miniuser\" : \"gh_744d2ebca056\",\n  \"appid\" : \"wxde49e54377b35da9\"\n}";

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
            Map dataStr = await FlutterFlappyPay.yunPay(
              payStr,
              "",
              "",
              YunPayType.TYPE_WX,
            );
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
