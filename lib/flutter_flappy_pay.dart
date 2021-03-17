import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

enum YunPayType {
  //微信支付
  TYPE_WX,
  //支付宝支付
  TYPE_ALI,
  //银联支付
  TYPE_UMS,
}

class FlutterFlappyPay {
  //channel
  static const MethodChannel _channel = const MethodChannel('flutter_flappy_pay');

  //支付宝授权
  static Future<Map?> aliAuth(String authInfo, String appScheme, bool androidFlag) async {
    final String data = await _channel.invokeMethod('aliAuth', <String, dynamic>{
      'authInfo': authInfo,
      'appScheme': appScheme,
      'flag': androidFlag ? "1" : "0",
    });
    return jsonDecode(data);
  }

  //支付宝支付
  static Future<Map?> aliPay(String payInfo, String appScheme, bool androidFlag) async {
    final String data =await _channel.invokeMethod('aliPay', <String, dynamic>{
      'payInfo': payInfo,
      'appScheme': appScheme,
      'flag': androidFlag ? "1" : "0",
    });
    return jsonDecode(data);
  }

  //进行微信支付
  static Future<Map?> wxPay(String payInfo, String appScheme, String universalLink) async {
    final String data = await _channel.invokeMethod('wxPay', <String, dynamic>{
      'payInfo': payInfo,
      'appScheme': appScheme,
      'universalLink': universalLink,
    });
    return jsonDecode(data);
  }

  //使用银联支付
  static Future<Map?> yunPay(String payInfo, String appScheme, String universalLink, YunPayType payChannel) async {
    int type = 0;
    switch (payChannel) {
      case YunPayType.TYPE_WX:
        type = 0;
        break;
      case YunPayType.TYPE_ALI:
        type = 1;
        break;
      case YunPayType.TYPE_UMS:
        type = 2;
        break;
    }
    final String data = await _channel.invokeMethod('yunPay', <String, dynamic>{
      'payInfo': payInfo,
      'appScheme': appScheme,
      'universalLink': universalLink,
      'payChannel': type.toString(),
    });
    return jsonDecode(data);
  }

  //支付
  static Future<Map?> yunCloudPay(String payInfo, String appScheme) async {
    final String data = await _channel.invokeMethod('yunCloudPay', <String, dynamic>{
      'payInfo': payInfo,
      'appScheme': appScheme,
    });
    return jsonDecode(data);
  }
}
