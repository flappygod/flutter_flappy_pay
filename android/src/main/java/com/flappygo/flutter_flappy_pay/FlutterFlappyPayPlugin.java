package com.flappygo.flutter_flappy_pay;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Message;

import androidx.annotation.NonNull;

import com.alipay.sdk.app.AuthTask;
import com.alipay.sdk.app.PayTask;
import com.chinaums.pppay.unify.UnifyPayListener;
import com.chinaums.pppay.unify.UnifyPayPlugin;
import com.chinaums.pppay.unify.UnifyPayRequest;
import com.flappygo.flutter_flappy_pay.wxapi.WxRegister;
import com.tencent.mm.opensdk.modelpay.PayReq;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;
import com.unionpay.UPPayAssistEx;
//import com.unionpay.UPPayAssistEx;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterFlappyPayPlugin
 */
public class FlutterFlappyPayPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    //上下文
    private Context context;

    //页面
    private Activity activity;

    //支付
    private static final int SDK_PAY_FLAG = 1;

    //认证
    private static final int SDK_AUTH_FLAG = 2;


    //支付对象
    private static class AliResultModel {
        Map<String, String> payResult;
        Result result;

        public Map<String, String> getPayResult() {
            return payResult;
        }

        public void setPayResult(Map<String, String> payResult) {
            this.payResult = payResult;
        }

        public Result getResult() {
            return result;
        }

        public void setResult(Result result) {
            this.result = result;
        }
    }


    //handler
    private static Handler mHandler = new Handler() {
        @SuppressWarnings("unused")
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case SDK_PAY_FLAG:
                case SDK_AUTH_FLAG: {
                    AliResultModel payModel = (AliResultModel) msg.obj;
                    JSONObject jsonObject = new JSONObject(payModel.payResult);
                    payModel.result.success(jsonObject.toString());
                    break;
                }
                default:
                    break;
            }
        }
    };

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_flappy_pay");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        context = null;
        activity = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        activity = null;
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {

        //支付宝授权
        if (call.method.equals("aliAuth")) {
            //授权信息
            final String authInfo = call.argument("authInfo");
            //flag
            final int flag = Integer.parseInt((String) call.argument("flag"));
            //返回
            Runnable authRunnable = new Runnable() {

                @Override
                public void run() {
                    // 构造AuthTask 对象
                    AuthTask authTask = new AuthTask(activity);
                    // 调用授权接口，获取授权结果
                    Map<String, String> authReslut = authTask.authV2(authInfo, flag == 1 ? true : false);
                    //组装
                    AliResultModel payModel = new AliResultModel();
                    payModel.setResult(result);
                    payModel.setPayResult(authReslut);
                    //授权成功
                    Message msg = new Message();
                    msg.what = SDK_AUTH_FLAG;
                    msg.obj = payModel;
                    mHandler.sendMessage(msg);
                }
            };
            // 必须异步调用
            Thread authThread = new Thread(authRunnable);
            //开始
            authThread.start();
        }
        //支付宝支付
        else if (call.method.equals("aliPay")) {
            //订单信息
            final String payInfo = call.argument("payInfo");
            //flag
            final int flag = Integer.parseInt((String) call.argument("flag"));
            //创建支付
            final Runnable payRunnable = new Runnable() {
                @Override
                public void run() {
                    //支付
                    PayTask alipay = new PayTask(activity);
                    //调用支付
                    Map<String, String> payResult = alipay.payV2(payInfo, flag == 1 ? true : false);
                    //组装参数
                    AliResultModel payModel = new AliResultModel();
                    payModel.setResult(result);
                    payModel.setPayResult(payResult);
                    //支付结果
                    Message msg = new Message();
                    msg.what = SDK_PAY_FLAG;
                    msg.obj = payModel;
                    mHandler.sendMessage(msg);
                }
            };
            // 必须异步调用
            Thread payThread = new Thread(payRunnable);
            // 必须异步调用
            payThread.start();
        }
        //微信支付支付
        else if (call.method.equals("wxPay")) {
            //订单信息
            final String payInfo = call.argument("payInfo");
            //设置微信支付回调
            WxRegister.setCallback(result);
            //准备支付参数
            try {
                JSONObject payParams = new JSONObject(payInfo);
                //支付
                PayReq wxPayReq = new PayReq();
                wxPayReq.appId = payParams.getString("appid");
                wxPayReq.partnerId = payParams.getString("partnerid");
                wxPayReq.prepayId = payParams.getString("prepayid");
                wxPayReq.nonceStr = payParams.getString("noncestr");
                wxPayReq.timeStamp = payParams.getString("timestamp");
                wxPayReq.packageValue = payParams.getString("package");
                wxPayReq.sign = payParams.getString("sign");
                //创建支付Api
                if (WxRegister.getWxAPi() == null) {
                    WxRegister.initWXAPI(wxPayReq.appId, activity.getApplicationContext());
                }
                //参数校验
                if (!wxPayReq.checkArgs()) {
                    result.success("{\"errCode\":\"-1\",\"errStr\":\"支付失败，参数校验不通过\"}");
                    return;
                }
                //发送支付请求
                if (!WxRegister.getWxAPi().sendReq(wxPayReq)) {
                    result.success("{\"errCode\":\"-1\",\"errStr\":\"支付失败，微信请求失败\"}");
                }
            } catch (Exception e) {
                result.success("{\"errCode\":\"-1\",\"errStr\":\"支付失败，参数格式错误\"}");
            }
        }
        //银联支付
        else if (call.method.equals("yunPay")) {
            //订单信息
            final String payInfo = call.argument("payInfo");
            //flag
            final int flag = Integer.parseInt((String) call.argument("payChannel"));
            //微信
            if (flag == 0) {
                UnifyPayRequest request = new UnifyPayRequest();
                request.payChannel = UnifyPayRequest.CHANNEL_WEIXIN;
                request.payData = payInfo;
                UnifyPayPlugin.getInstance(context).setListener(new UnifyPayListener() {
                    @Override
                    public void onResult(String resultCode, String resultInfo) {
                        result.success("{\"resultCode\":\"" + resultCode + "\",\"resultInfo\":\"" + resultInfo + "\"}");
                    }
                });
                UnifyPayPlugin.getInstance(context).sendPayRequest(request);
            }
            //支付宝
            else if (flag == 1) {
                UnifyPayRequest request = new UnifyPayRequest();
                request.payChannel = UnifyPayRequest.CHANNEL_ALIPAY;
                request.payData = payInfo;
                UnifyPayPlugin.getInstance(context).setListener(new UnifyPayListener() {
                    @Override
                    public void onResult(String resultCode, String resultInfo) {
                        result.success("{\"resultCode\":\"" + resultCode + "\",\"resultInfo\":\"" + resultInfo + "\"}");
                    }
                });
                UnifyPayPlugin.getInstance(context).sendPayRequest(request);
            }
            //银联支付
            else if (flag == 2) {
                UnifyPayRequest request = new UnifyPayRequest();
                request.payChannel = UnifyPayRequest.CHANNEL_UMSPAY;
                request.payData = payInfo;
                UnifyPayPlugin.getInstance(context).setListener(new UnifyPayListener() {
                    @Override
                    public void onResult(String resultCode, String resultInfo) {
                        result.success("{\"resultCode\":\"" + resultCode + "\",\"resultInfo\":\"" + resultInfo + "\"}");
                    }
                });
                UnifyPayPlugin.getInstance(context).sendPayRequest(request);
            }


        }//银联云闪付
        else if (call.method.equals("yunCloudPay")) {
            try {
                //订单信息
                final String payInfo = call.argument("payInfo");
                //支付数据
                JSONObject jsonObject = new JSONObject(payInfo);
                //支付
                UPPayAssistEx.startPay(context, null, null, jsonObject.getString("tn"), "00");
            } catch (JSONException e) {
                result.success("{\"resultCode\":\"-1\",\"resultInfo\":\"支付失败，参数格式错误\"}");
            }

        }
        else {
            result.notImplemented();
        }
    }


}
