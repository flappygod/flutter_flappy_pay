#import "FlutterFlappyPayPlugin.h"
#import "UMSPPPayUnifyPayPlugin.h"

//当前plugin的引用
__weak FlutterFlappyPayPlugin* __plugin;

//实现
@implementation FlutterFlappyPayPlugin

//注册整个插件
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_flappy_pay"
                                     binaryMessenger:[registrar messenger]];
    FlutterFlappyPayPlugin* instance = [[FlutterFlappyPayPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    __plugin=instance;
}

//json转dic
+(NSDictionary *)jsonToDictionary:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

//dic转json
+(NSString*)dictionaryTojson:(NSDictionary *)json{
    //如果可以转为JSon
    if ([NSJSONSerialization isValidJSONObject:json]){
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];
        NSString *json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString* ret= [json stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        return ret;
    }
    return  nil;
}

//处理桥接方法
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    //保存当前的回调便于处理
    _result=result;
    
    //支付宝授权
    if ([@"aliAuth" isEqualToString:call.method]) {
        NSString* authInfo=call.arguments[@"authInfo"];
        NSString* appScheme=call.arguments[@"appScheme"];
        _aliScheme=appScheme;
        __weak typeof(self) safeSelf=self;
        //调用授权方法
        [[AlipaySDK defaultService] auth_V2WithInfo:authInfo
                                         fromScheme:appScheme
                                           callback:^(NSDictionary *json) {
            NSString* ret=[FlutterFlappyPayPlugin dictionaryTojson:json];
            if(safeSelf.result!=nil){
                safeSelf.result(ret);
                safeSelf.result=nil;
            }
        }];
    }
    //支付宝支付
    else if ([@"aliPay" isEqualToString:call.method]) {
        //获取支付信息
        NSString* payInfo=call.arguments[@"payInfo"];
        NSString* appScheme=call.arguments[@"appScheme"];
        _aliScheme=appScheme;
        __weak typeof(self) safeSelf=self;
        //调用支付结果开始支付
        [[AlipaySDK defaultService] payOrder:payInfo
                                  fromScheme:appScheme
                                    callback:^(NSDictionary *json) {
            NSString* ret=[FlutterFlappyPayPlugin dictionaryTojson:json];
            if(safeSelf.result!=nil){
                safeSelf.result(ret);
                safeSelf.result=nil;
            }
        }];
        
    }
    //微信支付
    else if ([@"wxPay" isEqualToString:call.method]) {
        //获取支付信息
        NSString* payInfo=call.arguments[@"payInfo"];
        NSString* appScheme=call.arguments[@"appScheme"];
        NSString* universalLink=call.arguments[@"universalLink"];
        _wxScheme=appScheme;
        //支付信息解析
        NSDictionary * payParam =  [FlutterFlappyPayPlugin jsonToDictionary:payInfo];
        //需要的
        NSArray *requiredParams = @[@"appid",@"partnerid", @"prepayid", @"timestamp", @"noncestr",@"package", @"sign"];
        for (NSString *key in requiredParams)
        {
            if (![payParam objectForKey:key])
            {
                NSString *resultString  = [NSString stringWithFormat:@"{\"errCode\":\"%d\",\"errStr\":\"%@\"}",-1,@"参数格式错误!"];
                if(_result!=nil){
                    _result(resultString);
                    _result=nil;
                }
                return ;
            }
        }
        //初始化微信API
        if(_wxInited==false){
            //初始化
            _wxInited=[WXApi registerApp: [payParam objectForKey:requiredParams[0]] universalLink:universalLink];
        }
        //支付
        PayReq *wxReq = [[PayReq alloc] init];
        wxReq.partnerId = [payParam objectForKey:requiredParams[1]];
        wxReq.prepayId = [payParam objectForKey:requiredParams[2]];
        wxReq.timeStamp = [[payParam objectForKey:requiredParams[3]] unsignedIntValue];
        wxReq.nonceStr = [payParam objectForKey:requiredParams[4]];
        wxReq.package = [payParam objectForKey:requiredParams[5]];
        wxReq.sign = [payParam objectForKey:requiredParams[6]];
        //跳转支付
        [WXApi sendReq:wxReq completion:^(BOOL success) {
            NSLog(@"onReq..wxReq.success.");
        }];
        
    }
    //调用银联支付
    else if ([@"yunPay" isEqualToString:call.method]) {
        NSString* payInfo=call.arguments[@"payInfo"];
        NSString* payChannel=call.arguments[@"payChannel"];
        NSString* universalLink=call.arguments[@"universalLink"];
        //解析
        NSDictionary* dic=[FlutterFlappyPayPlugin jsonToDictionary:payInfo];
        //0微信
        if(payChannel.intValue==0){
            //初始化微信API
            if(_umpInited==false){
                //初始化
                _umpInited=[UMSPPPayUnifyPayPlugin registerApp:dic[@"appid"]
                                                 universalLink:universalLink];
            }
            __weak typeof(self) safeSelf=self;
            [UMSPPPayUnifyPayPlugin payWithPayChannel:CHANNEL_WEIXIN
                                              payData:payInfo
                                        callbackBlock:^(NSString *resultCode, NSString *resultInfo) {
                        NSMutableDictionary* dic=[[NSMutableDictionary alloc]init];
                        dic[@"resultCode"]=resultCode;
                        dic[@"resultInfo"]=resultInfo;
                        NSString* ret=[FlutterFlappyPayPlugin dictionaryTojson:dic];
                        if(safeSelf.result!=nil){
                            safeSelf.result(ret);
                            safeSelf.result=nil;
                        }
            }];
        }
        //支付宝
        else if(payChannel.intValue==1){
            __weak typeof(self) safeSelf=self;
            [UMSPPPayUnifyPayPlugin payWithPayChannel:CHANNEL_ALIPAY
                                              payData:payInfo
                                        callbackBlock:^(NSString *resultCode, NSString *resultInfo) {
                        NSMutableDictionary* dic=[[NSMutableDictionary alloc]init];
                        dic[@"resultCode"]=resultCode;
                        dic[@"resultInfo"]=resultInfo;
                        NSString* ret=[FlutterFlappyPayPlugin dictionaryTojson:dic];
                        if(safeSelf.result!=nil){
                            safeSelf.result(ret);
                            safeSelf.result=nil;
                        }
            }];
        }
        //银联支付
        else if(payChannel.intValue==2){
            __weak typeof(self) safeSelf=self;
            [UMSPPPayUnifyPayPlugin payWithPayChannel:CHANNEL_UMSPAY
                                              payData:payInfo
                                        callbackBlock:^(NSString *resultCode, NSString *resultInfo) {
                        NSMutableDictionary* dic=[[NSMutableDictionary alloc]init];
                        dic[@"resultCode"]=resultCode;
                        dic[@"resultInfo"]=resultInfo;
                        NSString* ret=[FlutterFlappyPayPlugin dictionaryTojson:dic];
                        if(safeSelf.result!=nil){
                            safeSelf.result(ret);
                            safeSelf.result=nil;
                        }
            }];
        }
        
    }else {
        result(FlutterMethodNotImplemented);
    }
}


//处理Appdelegate返回数据
+(BOOL)handleOpenURL:(NSURL*)url{
    if(!__plugin){
        return NO;
    }
    return [__plugin handleOpenURL:url];
}

//处理
+(BOOL)handleOpenUniversalLink:(NSUserActivity *)userActivity delegate:(id)delegate{
    if(!__plugin){
        return NO;
    }
    return [WXApi handleOpenUniversalLink:userActivity delegate:__plugin];
}

//回调通知
- (BOOL)handleOpenURL:(NSURL*)url {
    NSLog(@"reslut = %@",url);
    NSLog(@"url.scheme = %@",url.scheme);
    //支付宝处理
    if( [url.scheme isEqualToString:_aliScheme] ){
        return [self handleAli:url];
    }
    //微信处理
    else if( [url.scheme isEqualToString:_wxScheme] ){
        return [WXApi handleOpenURL:url delegate:self];
    }
    return NO;
}

//处理支付宝的scheme回调
-(BOOL)handleAli:(NSURL*)url
{
    if ([url.host isEqualToString:@"safepay"])
    {
        __weak typeof(self) weakSelf=self;
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
            //返回数据
            if(weakSelf.result!=nil){
                weakSelf.result([FlutterFlappyPayPlugin dictionaryTojson:resultDic]);
                weakSelf.result=nil;
            }
        }];
        return YES;
    }
    return NO;
}

//处理微信的scheme回调
-(BOOL)handleWx:(NSURL*)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

//微信代理处理
- (void) onReq:(BaseReq *)req{
    NSLog(@"onReq....");
}

//微信代理处理
- (void) onResp:(BaseResp *)resp{
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        NSString *resultString;
        switch(resp.errCode){
            case 0:
                resultString= [NSString stringWithFormat:@"{\"errCode\":\"%d\",\"errStr\":\"%@\"}",resp.errCode,@"支付成功"];
                break;
            case -2:
                resultString= [NSString stringWithFormat:@"{\"errCode\":\"%d\",\"errStr\":\"%@\"}",resp.errCode,@"用户取消"];
                break;
            default:
                resultString= [NSString stringWithFormat:@"{\"errCode\":\"%d\",\"errStr\":\"%@\"}",resp.errCode,@"支付失败"];
                break;
        }
        NSLog(@"微信支付结果：%@", resultString);
        if(self.result!=nil){
            self.result(resultString);
            self.result=nil;
        }
    }
}


@end
