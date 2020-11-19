#import <Flutter/Flutter.h>
#import <AlipaySDK/AlipaySDK.h>
#import <WechatOpenSDK/WXApi.h>



@interface FlutterFlappyPayPlugin : NSObject<FlutterPlugin,WXApiDelegate>

//用户保留返回result
@property (nonatomic,strong) FlutterResult result;

//当前是否初始化
@property (nonatomic,assign) bool wxInited;

//当前是否初始化
@property (nonatomic,assign) bool umpInited;

//支付宝scheme
@property (nonatomic,copy) NSString* aliScheme;

//微信scheme
@property (nonatomic,copy) NSString* wxScheme;

//用于处理appdelegate
+(BOOL)handleOpenURL:(NSURL*)url;


//处理
+(BOOL)handleOpenUniversalLink:(NSUserActivity *)userActivity delegate:(id)delegate;

@end
