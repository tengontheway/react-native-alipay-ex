package com.plugins.alipay.AliPay;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;

import com.alipay.sdk.app.PayTask;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by admin on 2018/03/17.
 * 支付宝支付
 * 所有的订单信息都由服务器来生成
 */

public class AliPay {
    public static int SDK_PAY_FLAG=1;
    public static Callback AlipayCallback;

    /**
     * 支付宝支付
     * 所有的订单信息都由服务器来生成
     * https://docs.open.alipay.com/204/105465/
     * @param activity
     * @param order
     * @param callback
     */
    public void pay(final Activity activity, final String order, final Callback callback){
        Runnable payRunnable = new Runnable() {
            @Override
            public void run() {
                try {
                    PayTask alipay = new PayTask(activity);

                    AlipayCallback = callback;

                    Log.d("tzt", "tzt---------AlipayCallback:" + AlipayCallback);
                    Map<String, String> result = alipay.payV2(order, true);
                    Log.d("tzt", "tzt---------Runnable:" + result);

                    Message msg = new Message();
                    msg.what = SDK_PAY_FLAG;
                    msg.obj = result;
                    boolean ret = payHandler.sendMessageDelayed(msg, 200);
                    Log.d("tzt", "tzt---------sendMessageDelayed:" + ret);
                } catch (Exception e) {
                    Log.d("tzt", "tzt---------Exception:" + e);
                }
            }
        };

        Thread payThread = new Thread(payRunnable);
        payThread.start();
    }

//    /**
//     * 支付宝支付(老版本，用于参考)
//     * @param activity
//     * @param map
//     * @param callback
//     */
//    public static void payOrder(final Activity activity, final ReadableMap map, final Callback callback){
//        Runnable payRunnable = new Runnable() {
//            @Override
//            public void run() {
//                Log.d("tzt", "tzt-------------------map:" + map);
//                PayTask alipay = new PayTask(activity);
//
//                AlipayCallback = callback;
//                Map<String, String> keyValues = new HashMap<String, String>();
//                keyValues.put("app_id", map.getString("app_id"));
//                keyValues.put("method", map.getString("method"));
//                keyValues.put("charset", map.getString("charset"));
//                keyValues.put("sign",map.getString("sign"));
//                keyValues.put("sign_type", map.getString("sign_type").replace("\\/",""));
//                keyValues.put("timestamp", map.getString("timestamp"));
//                keyValues.put("version", map.getString("version"));
//                keyValues.put("notify_url",map.getString("notify_url"));
//
//
//                ReadableMap bizrnmap = map.getMap("biz_content");
//                JSONObject bizjson = new JSONObject();
//                Map<String, String> bizmap = new HashMap<String, String>();
//                try {
//                    bizjson.put("timeout_express",bizrnmap.getString("timeout_express"));
//                    bizjson.put("seller_id",bizrnmap.getString("seller_id"));
//                    bizjson.put("product_code",bizrnmap.getString("product_code"));
//                    bizjson.put("total_amount",bizrnmap.getString("total_amount"));
//                    bizjson.put("subject",bizrnmap.getString("subject"));
//                    bizjson.put("body",bizrnmap.getString("body"));
//                    bizjson.put("out_trade_no",bizrnmap.getString("out_trade_no"));
//
//                } catch (JSONException e) {
//                    e.printStackTrace();
//                }
//                String biz_content = bizjson.toString();
//                keyValues.put("biz_content",biz_content);
//
//                Log.d("tzt", "tzt---------keyValues:" + biz_content);
//                String orderInfo = buildOrderParam(keyValues,true);
//                Map<String, String> result = alipay.payV2(orderInfo, true);
//
//                Message msg = new Message();
//                msg.what = SDK_PAY_FLAG;
//                msg.obj = result;
//                payHandler.sendMessage(msg);
//            }
//        };
//
//        Thread payThread = new Thread(payRunnable);
//        payThread.start();
//    }




    @SuppressLint("HandlerLeak")
    private Handler payHandler = new Handler() {
        @SuppressWarnings("unused")
        public void handleMessage(Message msg) {
            Log.d("tzt", "tzt---------payHandler:" + msg);
            switch (msg.what) {
                case 1: {
                    AliPayResult payResult = new AliPayResult((Map<String, String>) msg.obj);
                    /**
                     对于支付结果，请商户依赖服务端的异步通知结果。同步通知结果，仅作为支付结束的通知。
                     */
                    String resultInfo = payResult.getResult();// 同步返回需要验证的信息
                    String resultStatus = payResult.getResultStatus();
                    Log.d("tzt", "tzt---------resultStatus:" + resultStatus);

                    // 判断resultStatus 为9000则代表支付成功
                    if (TextUtils.equals(resultStatus, "9000")) {
                        Log.d("tzt", "tzt---------resultStatus 9000:");
                        Log.d("tzt", "tzt---------AlipayCallback1:" + AlipayCallback);
                        if (AlipayCallback!=null){
                            WritableMap writableMap = new WritableNativeMap();
                            writableMap.putInt("code", 0);

                            Log.d("tzt", "tzt---------WritableMap1:" + writableMap);
                            AlipayCallback.invoke(writableMap);
                        }
                    } else {
                        Log.d("tzt", "tzt---------resultStatus:" + resultStatus);
                        Log.d("tzt", "tzt---------AlipayCallback2:" + AlipayCallback);
                        if (AlipayCallback!=null){
                            WritableMap writableMap = new WritableNativeMap();
                            writableMap.putInt("code", 1);
                            Log.d("tzt", "tzt---------WritableMap2:" + writableMap);
                            AlipayCallback.invoke(writableMap);
                        }
                    }

                    AlipayCallback=null;
                    break;
                }
                default:
                    break;
            }
        };
    };




}
