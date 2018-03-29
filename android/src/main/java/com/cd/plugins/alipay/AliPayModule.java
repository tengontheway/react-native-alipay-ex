package com.cd.plugins.alipay;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import com.alipay.sdk.app.PayTask;
import com.facebook.common.util.ExceptionWithNoStacktrace;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.plugins.alipay.AliPay.AliPay;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.plugins.alipay.AliPay.AliPayResult;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * Created by admin on 2016/12/20.
 * AliPay支付接口
 */
public class AliPayModule extends ReactContextBaseJavaModule{
    private Toast mToast;

    public AliPayModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "AliPayModule";
    }


    public static int SDK_PAY_FLAG=1;
    public static Callback AlipayCallback;

    /**
     * 支付宝支付
     * 所有的订单信息都由服务器来生成
     * https://docs.open.alipay.com/204/105465/
     * @param order 组合好后的订单字符串
     * @param callback
     * {
     *     code: 0 成功, 非0 失败
     * }
     */
    @ReactMethod
    public void pay( final String order, final Callback callback){
        Runnable payRunnable = new Runnable() {
            @Override
            public void run() {
                try {
                    PayTask alipay = new PayTask(getCurrentActivity());

                    AlipayCallback = callback;

                    Log.d("tzt", "tzt---------AlipayCallback:" + AlipayCallback);
                    Map<String, String> result = alipay.payV2(order, true);
                    Log.d("tzt", "tzt---------Runnable:" + result);

                    Message msg = new Message();
                    msg.what = SDK_PAY_FLAG;
                    msg.obj = result;
                    payHandler.sendMessage(msg);
                } catch (Exception e) {
                    WritableMap writableMap = new WritableNativeMap();
                    writableMap.putInt("code", 1);
                    AlipayCallback.invoke(writableMap);

                    Log.d("tzt", "tzt---------pay exception!");
                }
            }
        };

        Thread payThread = new Thread(payRunnable);
        payThread.start();
    }

    @SuppressLint("HandlerLeak")
    private Handler payHandler = new Handler(getReactApplicationContext().getMainLooper()) {
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

                    // 判断resultStatus 为9000则代表支付成功
                    if (TextUtils.equals(resultStatus, "9000")) {
                        if (AlipayCallback!=null){
                            WritableMap writableMap = new WritableNativeMap();
                            writableMap.putInt("code", 0);
                            AlipayCallback.invoke(writableMap);
                        }
                    } else {
                        if (AlipayCallback!=null){
                            WritableMap writableMap = new WritableNativeMap();
                            writableMap.putInt("code", 1);
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


    @ReactMethod
    public void show(ReadableMap map){
        if(mToast == null) {
            mToast = Toast.makeText(getCurrentActivity(), map.getString("message"), Toast.LENGTH_SHORT);
        } else {
            mToast.setText(map.getString("message"));
            mToast.setDuration(Toast.LENGTH_SHORT);
        }
        mToast.show();
    }


    /**
     * 构造支付订单参数信息
     *
     * @param map
     * 支付订单参数
     * @return
     */
    private static String buildOrderParam(Map<String, String> map,boolean isgo) {
        List<String> keys = new ArrayList<String>(map.keySet());

        //实现排序方法
        Collections.sort(keys);

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < keys.size() - 1; i++) {
            String key = keys.get(i);
            String value = map.get(key);
            sb.append(buildKeyValue(key, value, isgo));
            sb.append("&");
        }

        String tailKey = keys.get(keys.size() - 1);
        String tailValue = map.get(tailKey);
        sb.append(buildKeyValue(tailKey, tailValue, true));

        return sb.toString();
    }

    /**
     * 拼接键值对
     *
     * @param key
     * @param value
     * @param isEncode
     * @return
     */
    private static String buildKeyValue(String key, String value, boolean isEncode) {
        StringBuilder sb = new StringBuilder();
        sb.append(key);
        sb.append("=");
        if (isEncode) {
            try {
                sb.append(URLEncoder.encode(value, "UTF-8"));
            } catch (UnsupportedEncodingException e) {
                sb.append(value);
            }
        } else {
            sb.append(value);
        }
        return sb.toString();
    }


    //方法返回的就是10位的时间戳
    private static String getTime(){

        long time=System.currentTimeMillis()/1000;//获取系统时间的10位的时间戳

        String  str=String.valueOf(time);

        return str;

    }

}
