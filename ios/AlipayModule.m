//
//  ViewController.m
//  AliSDKDemo
//
//  Created by antfin on 17-10-24.
//  Copyright (c) 2017年 AntFin. All rights reserved.
//
/**
 回调参数 params =
 {
 code: 0,     // 手动插入
 memo: "";
 result: "{\"alipay_trade_app_pay_response\":{\"code\":\"10000\",\"msg\":\"Success\",\"app_id\":\"2018030502319440\",\"auth_app_id\":\"2018030502319440\",\"charset\":\"utf-8\",\"timestamp\":\"2018-03-21 18:39:48\",\"total_amount\":\"0.01\",\"trade_no\":\"2018032121001004570568419543\",\"seller_id\":\"2088621971848763\",\"out_trade_no\":\"55a814350eb2f86e9fc67530785036fa\"},\"sign\":\"IW6U9h4aFdLN3vR8igizUiTitOmeqpZz3eiw6CHZBTnKAcclxoUbqxKPf2FFchG7ixUnygYGgb2iPTyeOYZXUY6Oykh18mT6nbxQAzVsYQaQynqNOYwQbOmRFPj6kaUHRmu4J+BjxxNYj0ptWI8uRx2WGx4WgegviLXAryGGfyAdJGZussmC0HplqescLUR7kiGe0LnjwkVctaIyMeywy0F2jsIOIdq+9co2VUioMorLv7vFD9y4Vd0h8z0FNpSEqMugyIJyc+RfVAODhfIs0/wneywKyn9EBpV1vvQS7J7d/+ndoIMTjOm8Uglz1Q1+e0PjMuGMS+IbwpH4lcE+yA==\",\"sign_type\":\"RSA2\"}";
 resultStatus: 9000;
 }
 **/

#import "AliPayModule.h"
#import <AlipaySDK/AlipaySDK.h>
#import "APAuthInfo.h"
#import "APOrderInfo.h"
#import "APRSASigner.h"
//#import "APWebViewController.h"

static RCTResponseSenderBlock _result_back;

static NSString *const kOpenURLNotification = @"RCTOpenURLNotification";

//@interface AliPayModule ()
//
//@property(nonatomic, strong)APWebViewController *webvc;
//@property (nonatomic, copy) RCTResponseSenderBlock alipay_block;
//
//@end


@implementation AliPayModule

RCT_EXPORT_MODULE()

RCTResponseSenderBlock _alertCallback;
- (NSArray<NSString *> *)supportedEvents {
  return @[];
}

/**
 回调参数 params =
 {
 code: 0,     // 手动插入
 memo: "";
 result: "{\"alipay_trade_app_pay_response\":{\"code\":\"10000\",\"msg\":\"Success\",\"app_id\":\"2018030502319440\",\"auth_app_id\":\"2018030502319440\",\"charset\":\"utf-8\",\"timestamp\":\"2018-03-21 18:39:48\",\"total_amount\":\"0.01\",\"trade_no\":\"2018032121001004570568419543\",\"seller_id\":\"2088621971848763\",\"out_trade_no\":\"55a814350eb2f86e9fc67530785036fa\"},\"sign\":\"IW6U9h4aFdLN3vR8igizUiTitOmeqpZz3eiw6CHZBTnKAcclxoUbqxKPf2FFchG7ixUnygYGgb2iPTyeOYZXUY6Oykh18mT6nbxQAzVsYQaQynqNOYwQbOmRFPj6kaUHRmu4J+BjxxNYj0ptWI8uRx2WGx4WgegviLXAryGGfyAdJGZussmC0HplqescLUR7kiGe0LnjwkVctaIyMeywy0F2jsIOIdq+9co2VUioMorLv7vFD9y4Vd0h8z0FNpSEqMugyIJyc+RfVAODhfIs0/wneywKyn9EBpV1vvQS7J7d/+ndoIMTjOm8Uglz1Q1+e0PjMuGMS+IbwpH4lcE+yA==\",\"sign_type\":\"RSA2\"}";
 resultStatus: 9000;
 }
 **/
+(void) handleResult:(NSDictionary *)resultDic
{
  NSMutableDictionary* body = [[NSMutableDictionary alloc] initWithDictionary:resultDic];
  
  NSString *status = resultDic[@"resultStatus"];
  if ([status integerValue] >= 8000) {
    body[@"code"] = [NSNumber numberWithInt:0];
    
    _result_back(@[body]);
  } else {
    body[@"code"] = [NSNumber numberWithInt:1];
    
    _result_back(@[body]);
    
  }
}

+(void) handleOpenURL:(NSURL *)url
{
  //如果极简开发包不可用，会跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给开发包
  if ([url.host isEqualToString:@"safepay"]) {
    // 真机支付宝APP回调
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
      //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
      [self handleResult:resultDic];
    }];
  }
  
  if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回authCode
    
    [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
      //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
      [self handleResult:resultDic];
      
    }];
  }
}

#pragma mark -
#pragma mark   ==============点击订单模拟支付行为==============


//
// 选中商品调用支付宝极简支付
//
RCT_EXPORT_METHOD(pay: (NSString *)order result_back:(RCTResponseSenderBlock)result_back)
{
  _result_back = result_back;
  
  // NOTE: 调用支付结果开始支付
  [[AlipaySDK defaultService] payOrder:order fromScheme: [self appScheme] callback:^(NSDictionary *resultDic) {
    // 支付宝HTML5支付回调
    [AliPayModule handleResult:resultDic];
    NSLog(@"reslut_Alipay = %@",resultDic);
  }];
}

RCT_EXPORT_METHOD(getVersion:(RCTPromiseResolveBlock)resolve) {
  resolve(AlipaySDK.defaultService.currentVersion);
}

//应用注册scheme,在Info.plist定义URL types
- (NSString *)appScheme {
  NSArray *urlTypes = NSBundle.mainBundle.infoDictionary[@"CFBundleURLTypes"];
  for (NSDictionary *urlType in urlTypes) {
    NSString *urlName = urlType[@"CFBundleURLName"];
    if ([urlName hasPrefix:@"alipay"]) {
      NSArray *schemes = urlType[@"CFBundleURLSchemes"];
      return schemes.firstObject;

    }
  }
  return nil;
}


//////////////////////////////////////客户端填充订单参数////////////////////////////////////////////////////

//
////
//// 选中商品调用支付宝极简支付
////
//RCT_EXPORT_METHOD(doAPPay: (NSDictionary *)options result_back:(RCTResponseSenderBlock)result_back)
//{
////  self.alipay_block = result_back;
//  NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
//  [defaultCenter addObserver:self selector:@selector(getAlipayResult:) name: ALIPAY_NOTIFY object:nil];
//
//  NSString *appID = APP_ID;
//  if ([appID length] == 0)
//  {
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
//                                                                   message:@"缺少appId,请检查参数设置"
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了"
//                                                     style:UIAlertActionStyleDefault
//                                                   handler:^(UIAlertAction *action){
//
//                                                   }];
//    [alert addAction:action];
//    return;
//  }
//
//  /*
//   *生成订单信息及签名
//   */
//  //将商品信息赋予AlixPayOrder的成员变量
//  APOrderInfo* order = [APOrderInfo new];
//  order.notify_url = NOTIFY_URL;
//  // NOTE: app_id设置
//  order.app_id = appID;
//
//  // NOTE: 支付接口名称
//  order.method = ORDER_METHOD;
//
//  // NOTE: 参数编码格式
//  order.charset = ORDER_CHAREST;
//
//  // NOTE: 当前时间点
//  //    NSDateFormatter* formatter = [NSDateFormatter new];
//  //    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//  //    order.timestamp = [formatter stringFromDate:[NSDate date]];
//  order.timestamp =  [options objectForKey:@"timestamp"];
//  // NOTE: 支付版本
//  order.version = ORDER_VERSION;
//
//  // NOTE: sign_type 根据商户设置的私钥来决定
//  //    order.sign_type = (rsa2PrivateKey.length > 1)?@"RSA2":@"RSA";
//  order.sign_type = [options objectForKey:@"sign_type"];
//  // NOTE: 商品数据   ****需要传递的数据******
//  order.biz_content = [APBizContent new];
//  order.biz_content.body = [options objectForKey:@"body"];
//  order.biz_content.subject = [options objectForKey:@"subject"];
//  //    order.biz_content.out_trade_no = [self generateTradeNO]; //订单ID（由商家自行制定）
//  order.biz_content.out_trade_no = [options objectForKey: @"out_trade_no"];
//  order.biz_content.timeout_express = CONTENT_TIMEOUT; //超时时间设置
//  order.biz_content.total_amount = [NSString stringWithFormat:@"%.2f", 0.01]; //商品价格
//  NSLog(@"orderInfo---------: %@",order);
//  //将商品信息拼接成字符串
//  //    NSString *orderInfo = [order orderInfoEncoded:NO];
//  NSString *orderInfoEncoded = [order orderInfoEncoded:YES];
//
//  // NOTE: 获取私钥并将商户信息签名，外部商户的加签过程请务必放在服务端，防止公私钥数据泄露；
//  //       需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
//  NSString *signedString =  [options objectForKey: @"sign"] ;
//
//  //    APRSASigner* signer = [[APRSASigner alloc] initWithPrivateKey:((rsa2PrivateKey.length > 1)?rsa2PrivateKey:rsaPrivateKey)];
//  //    NSLog(@"singedString_start--------%@", signer);
//  //    if ((rsa2PrivateKey.length > 1)) {
//  //        signedString = [signer signString:orderInfo withRSA2:YES];
//  //    } else {
//  //        signedString = [signer signString:orderInfo withRSA2:NO];
//  //    }
//  // NOTE: 如果加签成功，则继续执行支付
//  if (signedString != nil) {
//    //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
//    NSString *appScheme = APP_SCHEME;
//
//    // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
//    NSString *orderString = [NSString stringWithFormat:@"%@&sign=%@",
//                             orderInfoEncoded, signedString];
//
//    // NOTE: 调用支付结果开始支付
//    NSLog(@"orderString ====== %@",orderString);
//    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
////      self.alipay_block (@[resultDic]);
//      NSLog(@"reslut_Alipay = %@",resultDic);
//    }];
//  }
//}


#pragma mark -
#pragma mark   ==============产生随机订单号==============

- (NSString *)generateTradeNO
{
  static int kNumber = 15;
  NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  NSMutableString *resultStr = [[NSMutableString alloc] init];
  srand((unsigned)time(0));
  for (int i = 0; i < kNumber; i++)
  {
    unsigned index = rand() % [sourceStr length];
    NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
    [resultStr appendString:oneStr];
  }
  return resultStr;
}



@end

