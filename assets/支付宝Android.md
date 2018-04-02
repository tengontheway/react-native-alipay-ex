# 一.支付宝接入文档
## Android接入入口
https://docs.open.alipay.com/204

根据文档，添加alipaySdk-201*****.jar包，然后根据文档配置

## 规则
签名网址，所有的参数排序encode附带签名组合成的url地址，由服务器生成后给客户端，客户端不再校验这些参数


----------------------------------------------------------------------------------------

# 二.请求参数组装步骤
支付宝2.0sdk集成时的难点在于订单参数顺序的一致性，即提交给服务器的订单参数顺序，和要与服务器签名的订单参数顺序相一致。
官方链接: https://docs.open.alipay.com/204/105465/

## 1.构造所有的订单参数
需要排序(划重点)

Android 排序
```
List<String> keys = new ArrayList<String>(map.keySet());

//实现排序方法
Collections.sort(keys);
```

iOS 排序
```
 NSArray* sortedKeyArray = [[tmpDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
    return [obj1 compare:obj2];
}];
```

请求参数按照key=value&key=value方式拼接的未签名原始字符串：
```
app_id=2015052600090779&biz_content={"timeout_express":"30m","product_code":"QUICK_MSECURITY_PAY","total_amount":"0.01","subject":"1","body":"我是测试数据","out_trade_no":"IQJZSRC1YMQB5HU"}&charset=utf-8&format=json&method=alipay.trade.app.pay&notify_url=http://domain.merchant.com/payment_notify&sign_type=RSA2&timestamp=2016-08-25 20:26:31&version=1.0
```

## 2.再对原始字符串进行签名，参考签名规则：
```
app_id=2015052600090779&biz_content={"timeout_express":"30m","product_code":"QUICK_MSECURITY_PAY","total_amount":"0.01","subject":"1","body":"我是测试数据","out_trade_no":"IQJZSRC1YMQB5HU"}&charset=utf-8&format=json&method=alipay.trade.app.pay&notify_url=http://domain.merchant.com/payment_notify&sign_type=RSA2&timestamp=2016-08-25 20:26:31&version=1.0&sign=cYmuUnKi5QdBsoZEAbMXVMmRWjsuUj+y48A2DvWAVVBuYkiBj13CFDHu2vZQvmOfkjE0YqCUQE04kqm9Xg3tIX8tPeIGIFtsIyp/M45w1ZsDOiduBbduGfRo1XRsvAyVAv2hCrBLLrDI5Vi7uZZ77Lo5J0PpUUWwyQGt0M4cj8g=
```
相对于上一步多了 &sign=XXXXXXXXX


## 3.最后对请求字符串的所有一级value（biz_content作为一个value）进行encode，编码格式按请求串中的charset为准，没传charset按UTF-8处理，获得最终的请求字符串
只是对value进行url编码而不是全部进行url编码，key不需要编码



----------------------------------------------------------------------------------------

# 常见问题

## Q：移动支付请求参数的顺序？
A：请求参数需要排序，签名前请先排序。
链接：https://docs.open.alipay.com/204/105849

## Q：安卓手机在没有安装支付宝客户端的情况下，调试代码唤不起H5收银台怎么办？
A：请查看配置文件AndroidManifest.xml，必须和demo一样（主要是activity这一部分），具体配置如下：
```
<activity
    android:name="com.alipay.sdk.pay.demo.PayDemoActivity"
    android:icon="@drawable/msp_icon"
    android:label="@string/app_name">
    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
    </intent-filter>
</activity>

<!-- alipay sdk begin -->
<activity
    android:name="com.alipay.sdk.app.H5PayActivity"
    android:configChanges="orientation|keyboardHidden|navigation"
    android:exported="false"
    android:screenOrientation="behind"
    android:windowSoftInputMode="adjustResize|stateHidden" >
</activity>
```

## APP集成支付宝，服务端该怎么设计呢?
1.客户端选购商品，提交商品信息到服务端（Client->[{商品1,1件,￥100},{商品1,1件,￥100}]->Server)
2.服务端订单入库生成订单号反馈给客户端(Server->[2333333,￥200]->Client)
3.调用支付宝SDK携带一些参数(23333333,￥200, http://domain/payment_notify )（SDK干了什么只有支付宝知道）
4.用户支付完成，支付宝服务器通知应用服务器（HTTP访问http://domain/payment_notify），服务器做验证判断支付是否成功。
5.支付完成后，回到APP，APP收到通知，访问服务器接口验证是否成功。

## App支付FAQ
链接：https://docs.open.alipay.com/204/105849

## Q:签名url生成
A：签名url都由服务器生成

## Q:重复使用服务器返回的签名url(支付宝已验签过)
A: 客户端直接弹出支付宝提示: "ALI38869 交易已经支付，请勿重新付款!"

## Android下支付成功、取消支付、支付失败收不到回调
```
Message msg = new Message();
msg.what = SDK_PAY_FLAG;
msg.obj = result;
payHandler.sendMessage(msg);
```
payHandler 中收不到回调，原因是创建handler时需要放入到MainLooper中
```
private Handler payHandler = new Handler(getReactApplicationContext().getMainLooper())
```