//
//  IMService.m
//  itelNSC
//
//  Created by nsc on 14-5-26.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "IMService.h"
#import "SocketConnector.h"
@implementation IMService
static IMService *instance;
+(instancetype)defaultService{
    return instance;
}
+ (void)initialize
{
    if (self == [IMService class]) {
        static BOOL didInit=NO;
        if (didInit==NO) {
            instance =[[IMService alloc]init];
            didInit=YES;
        }
    }
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.socketConnector=[[SocketConnector alloc]init];
    }
    return self;
}
-(void)connectToSignalServer{
    [self.socketConnector getSignalIP];
     RACDisposable *disposable= [[RACObserve(self, socketConnector.signalServerIP) map:^id(NSString *value) {
         if (value) {
             [self.socketConnector connect];
         }
         return value;
     }]subscribeNext:^(id x) {
         [disposable dispose];
     }];
    [[self.socketConnector socketDataSignal] subscribeNext:^(id x) {
        NSLog(@"有数据来啦 %@",x);
    }];
}
@end
