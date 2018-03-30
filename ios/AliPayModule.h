//
//  ViewController.h
//  AliSDKDemo
//
//  Created by antfin on 17-10-24.
//  Copyright (c) 2017年 AntFin. All rights reserved.
//

#ifndef AliPayModule_h
#define AliPayModule_h
#import <React/RCTEventEmitter.h>
#import <React/RCTBridgeModule.h>

@interface AliPayModule: RCTEventEmitter <RCTBridgeModule>

+(void) handleOpenURL:(NSURL *)url;

@end

#endif /* AliPayModule_h */
