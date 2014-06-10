//
//  IMService.h
//  itelNSC
//
//  Created by nsc on 14-5-26.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SocketConnector;
@class sdk;

NS_ENUM(NSInteger, IMsessionType){
    IMsessionTypeEdle,
    IMsessionTypeCalling,
    IMsessionTypeAnsering,
    IMsessionTypeInSession
};


@interface IMService : NSObject
+(instancetype)defaultService;
@property (nonatomic)  SocketConnector *socketConnector;
-(void)connectToSignalServer;
-(void)connectSuccess:(RACSignal*)signal;
-(void)vcall:(NSString*)itel;
-(UIView*)getCametaViewLocal;
-(int)openScreen:(UIView*)view;
-(void)haltSession:(NSString*)haltType;
-(void)answer:(BOOL)useVideo;
@property (nonatomic) NSNumber *useVideo;
@property (nonatomic) sdk *avSdk;
@property (nonatomic) long  SSID;
@property (nonatomic) NSNumber *sessionType;
@property (nonatomic) NSString *sessionState;
@property (nonatomic) NSString *peerAccount;
@property (nonatomic) NSDictionary *peerCallingData;
@end
