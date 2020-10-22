#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "FlutterFlappyPayPlugin.h"
#import <WechatOpenSDK/WXApi.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

/**
回调通知
*/
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [FlutterFlappyPayPlugin handleOpenURL:url];
}
// ios 9.0+
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    return [FlutterFlappyPayPlugin handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    return [FlutterFlappyPayPlugin handleOpenUniversalLink:userActivity delegate:self];
}

@end
