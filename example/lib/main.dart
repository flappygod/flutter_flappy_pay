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

  String payStr="app_id=2016100100636021&timestamp=2016-07-29+16%3A55%3A53&biz_content=%7B%22timeout_express%22%3A"
      "%2230m%22%2C%22product_code%22%3A%22QUICK_MSECURITY_PAY%22%2C%22total_amount%22%3A%220.01%22%2C%22subject%22%3A%221%22%2C%22body%22%3A%22%E6%88%91%E6%98%AF%E6%B5%8B%E8%AF%95%E6%95%B0%E6%8D%AE%22%2C%22out_trade_no%22%3A%221022151551-1168%22%7D&method=alipay.trade.app.pay&charset=utf-8&version=1.0&sign_type=RSA2&sign=CBXXeVIJUxfB26xpmwt46e6%2FmTHp2Mhlj2TtxTUhcjJ9%2FapGqUiZ9mv452eBW6dnOGd5JVLmCQPb7Qc6KRaRFfGxo%2F8Lw0Zx8PpeyQ33ukGdL2YZG240BsAAuVzxNw8D3ak98O64v6K9kc0gzdITjU3EOkSgs8euLdw%2FbAHVxZTqLf7hbxYz%2B9dZ8zzKdP7Aj8jJH%2Fmlzaspm2hNReqpJXIY5mpEGGylYt4LtwsGzpoWixdiSpHvilHpONhqHxuqg%2Bm%2FUmgP03KK2%2B8f6Szm3bC8wG1J%2BzHVpuFPlb8Hu%2FAYBhhNA708IBlUnybV09RKyrxWpm8ZPPBuSt4xDh9kcg%3D%3D";

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
            Map  dataStr=await FlutterFlappyPay.aliPay(payStr, "testdemo", true);
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
