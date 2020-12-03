package com.flappygo.flutter_flappy_pay.wxapi;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.chinaums.pppay.unify.UnifyPayPlugin;
import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.modelbiz.WXLaunchMiniProgram;
import com.tencent.mm.opensdk.modelpay.PayResp;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class WXPayEntryActivity extends Activity implements IWXAPIEventHandler {
    private static final String TAG = "WXPayEntryActivity";
    //微信支付
    private IWXAPI wxApi = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        wxApi = WxRegister.getWxAPi();
        //这里是微信官方的返回方法回调
        if (wxApi != null) {
            wxApi.handleIntent(getIntent(), this);
        }
        //银联的没有进行初始化
        else {
            wxApi = WXAPIFactory.createWXAPI(this, UnifyPayPlugin.getInstance(this).getAppId());
            wxApi.handleIntent(getIntent(), this);
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        wxApi.handleIntent(intent, this);
    }

    @Override
    public void onReq(BaseReq baseReq) {
        Log.e(TAG, "req");
    }

    @Override
    public void onResp(BaseResp baseResp) {

        //支付结果接收
        if (baseResp.getType() == ConstantsAPI.COMMAND_LAUNCH_WX_MINIPROGRAM) {
            UnifyPayPlugin.getInstance(this).getWXListener().onResponse(this, baseResp);
            return;
        }

        Log.e(TAG, "微信支付回调");
        if (WxRegister.getCallback() == null) {
            Log.d(TAG, "CallbackContext 无效");
            startMainActivity();
            return;
        }

        Map<String, String> resultMap = new HashMap<String, String>();
        resultMap.put("errCode", "" + baseResp.errCode);
        resultMap.put("errStr", baseResp.errStr);
        resultMap.put("transaction", baseResp.transaction);
        resultMap.put("openId", baseResp.openId);

        switch (baseResp.getType()) {
            case ConstantsAPI.COMMAND_PAY_BY_WX: {
                PayResp wxPayResp = (PayResp) baseResp;
                resultMap.put("prepayId", wxPayResp.prepayId);
                resultMap.put("extData", wxPayResp.extData);
                resultMap.put("returnKey", wxPayResp.returnKey);
            }
            break;
        }

        Log.d(TAG, "wechat return ::" + resultMap.toString());
        JSONObject jsonObject = new JSONObject(resultMap);
        WxRegister.getCallback().success(jsonObject.toString());

        finish();
    }

    //启动主页面
    protected void startMainActivity() {
        Intent intent = getPackageManager().getLaunchIntentForPackage(getPackageName());
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        getApplicationContext().startActivity(intent);
    }
}
