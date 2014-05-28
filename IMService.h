//
//  IMService.h
//  itelNSC
//
//  Created by nsc on 14-5-26.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SocketConnector;
@interface IMService : NSObject
+(instancetype)defaultService;
@property (nonatomic)  SocketConnector *socketConnector;
-(void)connectToSignalServer;
@end
