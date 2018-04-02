# iOS支付宝接入文档

# 规范
1.签名网址，所有的参数排序encode附带签名组合成的url地址，由服务器生成后给客户端，客户端不再校验这些参数
2.所有的插件都以XXModule的形式导出. eg.AliPayModule.h/m => NativeModules.AliPayModule


支付宝插件路径：
```
--plugins
    --alipay
        --AliPayModule.h
        --AliPayModule.m
        --headers
            --openssl
                --APRSASigner.h
                --**
            --Utils
                --**
        --libs
            --AlipaySDK.bundle
            --AlipaySDK.framework
            --libcrypto.a
            --libssl.a
```
AliPayModule.m是核心文件

# 配置参考
官方入口：https://docs.open.alipay.com/204/105295/

1.直接将plugins/alipay目录拖入到工程中

2.【无需配置】检查要添加的库是否正常添加，有无重复添加
`Build Phases` => `Link Binary with libraries` 和 `Copy Bundle Resources`

3.【无需配置】检查头文件、库文件引用
头文件： `Build Settings` =>`Header Search Paths`，属性为【recursive】递归查找头文件
```
$(SRCROOT)/plugins/alipay
```

库文件: `Build Settings` =>`Library Search Paths`
```
$(PROJECT_DIR)/plugins/alipay/libs
```

4.配置`URL Types`，保证支付后正常跳转  
`Info` => `URL Types`
Identifier 必须以 'alipay'开头，代码中有检测
```
alipay
```

“URL Schemes”输入独立的scheme，建议跟商户的app有一定的标示度，要做到和其他的商户app不重复，否则可能会导致支付宝返回的结果无法正确跳回商户app。
```
alipay_RNMAC*******
```

5.在`AppDelegate.m`中添加调用支付宝APP调用方法

```
#import "AlipayModule.h"        // Add

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{

  [AliPayModule handleOpenURL:url];         // Here add.

  return YES;
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
  [AliPayModule handleOpenURL:url];         // Here add.

  return YES;
}

```
支付宝的H5回调和支付宝app回调在两个位置，都需要处理
参考链接: https://github.com/myoula/react-native-payment-alipay

6.支付回调规范  
支付回调中必须加入 code: Integer(0)/Integer(1)，0表示无错误，1表示有错误
iOS/Android统一规范
```
code: 0,     // 手动插入
memo: "";
result: "{\"alipay_trade_app_pay_response\":{\"code\":\"10000\",\"msg\":\"Success\",\"app_id\":\"2018030502319440\",\"auth_app_id\":\"2018030502319440\",\"charset\":\"utf-8\",\"timestamp\":\"2018-03-21 18:39:48\",\"total_amount\":\"0.01\",\"trade_no\":\"2018032121001004570568419543\",\"seller_id\":\"2088621971848763\",\"out_trade_no\":\"55a814350eb2f86e9fc67530785036fa\"},\"sign\":\"IW6U9h4aFdLN3vR8igizUiTitOmeqpZz3eiw6CHZBTnKAcclxoUbqxKPf2FFchG7ixUnygYGgb2iPTyeOYZXUY6Oykh18mT6nbxQAzVsYQaQynqNOYwQbOmRFPj6kaUHRmu4J+BjxxNYj0ptWI8uRx2WGx4WgegviLXAryGGfyAdJGZussmC0HplqescLUR7kiGe0LnjwkVctaIyMeywy0F2jsIOIdq+9co2VUioMorLv7vFD9y4Vd0h8z0FNpSEqMugyIJyc+RfVAODhfIs0/wneywKyn9EBpV1vvQS7J7d/+ndoIMTjOm8Uglz1Q1+e0PjMuGMS+IbwpH4lcE+yA==\",\"sign_type\":\"RSA2\"}";
resultStatus: 9000;
```


# 常见问题
## Q:AppDelegate.m中，支付宝回调handleOpenURL,消息回调给JS端
A: 在`AliPayModule`中注册静态函数，消化在内部
参考: https://github.com/myoula/react-native-payment-alipay/blob/master/ios/AlipayModule/AlipayModule.m


## Q:签名url生成
A：签名url都由服务器生成

## Q:重复使用服务器返回的签名url(支付宝已验签过)
A: 客户端直接弹出支付宝提示: "ALI38869 交易已经支付，请勿重新付款!"




# 参考
react-native-payment-alipay promise回调调用  
https://github.com/myoula/react-native-payment-alipay

官方callback、promisecallback、thread回调  
https://facebook.github.io/react-native/docs/native-modules-ios.html

基本配置参考  
https://github.com/0x5e/react-native-alipay/blob/3639e6fa91392ab8831b8c6376b3abe63135e670/docs/ios-setup.md


