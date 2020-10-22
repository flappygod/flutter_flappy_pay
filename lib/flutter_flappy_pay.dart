import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class FlutterFlappyPay {
  //channel
  static const MethodChannel _channel = const MethodChannel('flutter_flappy_pay');

  //支付宝授权
  static Future<Map> aliAuth(String authInfo, String appScheme, bool androidFlag) async {
    final String data = await _channel.invokeMethod('aliAuth', <String, dynamic>{
      'authInfo': authInfo,
      'appScheme': appScheme,
      'flag': androidFlag ? "1" : "0",
    });
    return jsonDecode(data);
  }

  //支付宝支付
  static Future<Map> aliPay(String payInfo, String appScheme, bool androidFlag) async {
    final String data = await _channel.invokeMethod('aliPay', <String, dynamic>{
      'payInfo': payInfo,
      'appScheme': appScheme,
      'flag': androidFlag ? "1" : "0",
    });
    return jsonDecode(data);
  }

  //进行微信支付
  static Future<Map> wxPay(String payInfo, String appScheme, String universalLink) async {
    final String data = await _channel.invokeMethod('wxPay', <String, dynamic>{
      'payInfo': payInfo,
      'appScheme': appScheme,
      'universalLink': universalLink,
    });
    return jsonDecode(data);
  }
}
