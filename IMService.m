//
//  IMService.m
//  itelNSC
//
//  Created by nsc on 14-5-26.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "IMService.h"
#import "SocketConnector.h"
#import "ConstantHeader.h"
#import "sdk.h"
#import "MaoAppDelegate.h"
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
        self.socketConnector.service=self;
        self.avSdk=[[sdk alloc]init];
        [self.avSdk initMedia];
        self.sessionType=@(IMsessionTypeEdle);
        
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
    }

-(void)connectSuccess:(RACSignal*)signal{
        [self.socketConnector.socketDataSignal subscribeNext:^(NSDictionary *data) {
            NSInteger type = -1;
            //具体的数据
            NSDictionary *bodySection = @{};
            // 以是否具有head块作为解析依据。
            
            // 获取头部数据
            NSDictionary *headSection = [data valueForKey:kHead];
            if (headSection) {
                type = [[headSection valueForKey:kType] integerValue];
                NSInteger status = [[headSection valueForKey:kStatus] integerValue];
                // 异常情况处理。
                if (status != NORMAL_STATUS) {
                    [NSException exceptionWithName:@"500:data format error"
                                            reason:@"信令服务器返回数据状态不正常"
                                          userInfo:nil];
                    //如果收到的status不正常, 则触发该消息
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:SIGNAL_ERROR_NOTIFICATION
                     object:nil
                     userInfo:@{ kType : @(type) }];
                    return;
                }
                bodySection = [data valueForKey:kBody];
            } else {
                type = [[data valueForKey:kType] integerValue];
                bodySection = data;
            }
            
            //路由
            switch (type) {
                case SESSION_INIT_RES_TYPE:
                    // 通话查询请求正常返回，通知业务层
                    NSLog(@"%@",[bodySection objectForKey:@"description"]) ;
                    [self callingMessage:bodySection];
                    break;
                case SESSION_PERIOD_CALLING_TYPE:
                    NSLog(@"SESSION_PERIOD_CALLING_TYPE");
                    break;
                case SESSION_PERIOD_ANSWERING_TYPE:
                    [self callingResponse:bodySection];
                    break;
                case CMID_APP_LOGIN_SSS_RESP_TYPE: //信令服务器验证响应返回了，通知业务层
                    NSLog(@"CMID_APP_LOGIN_SSS_RESP_TYPE");
                    break;
                case SESSION_PERIOD_HALT_TYPE:
                    NSLog(@"SESSION_PERIOD_HALT_TYPE");
                    break;
                case CMID_APP_DROPPED_SSS_REQ_TYPE:
                    NSLog(@"CMID_APP_DROPPED_SSS_REQ_TYPE");
                    break;
                case HEART_BEAT_REQ_TYPE:
                    NSLog(@"HEART_BEAT_REQ_TYPE");
                    break;
                default:
                    break;
            }

        }];
}
#pragma mark - 获得摄像头View
-(UIView*)getCametaViewLocal{
    UIView *view=nil;
    if ([self.avSdk openCamera]) {
        view= [self.avSdk pViewLocal];
    }
   
    return view;
}
#pragma mark - 拨打
-(void)vcall:(NSString*)itel{
    
    self.useVideo=@(YES);
    [self checkPeer:itel];
    self.sessionType=@(IMsessionTypeCalling);
}
#pragma mark - 查询
-(void)checkPeer:(NSString*)peerItel{
    //构造通话信令
    self.sessionType=@(IMsessionTypeCalling);
    self.sessionState=@"正在查询对方信息...";
    
    NSUInteger seq=[self.socketConnector seq];
    NSDictionary *data = @{
                      kHead:@{
                              kType: [NSNumber numberWithInt:SESSION_INIT_REQ_TYPE],
                              kStatus:[NSNumber numberWithInt:NORMAL_STATUS],
                              kSeq:[NSNumber numberWithInteger:seq]
                              },
                      kBody:@{ kDestAccount : peerItel }
      
                      };
    [self.socketConnector sendRequest:data type:[@(SESSION_INIT_REQ_TYPE) integerValue]];
    
}
#pragma mark - 查询成功后 主叫信令流程
-(void)callingMessage:(NSDictionary*)data{
    
    [self.avSdk initNetwork];
    self.sessionState=@"查询成功！等待对方应答...";
    int selfNatType=[self.avSdk currentNATType];
      NSLog(@"当前本机的nat类型为:%d", selfNatType);
    //获取本机链路列表
    NSDictionary *address=(NSDictionary*)[self.avSdk endPointAddressWithProbeServer:data[@"relayip"] port:[data[@"relayport"]integerValue] bakPort:[data[@"bakport"] integerValue]];
    NSLog(@"本地外网地址:%@",address);
    NSMutableDictionary *callingData=[address mutableCopy];
    //构造主叫信令
    
    [callingData addEntriesFromDictionary:@{@"type":  @(SESSION_PERIOD_CALLING_TYPE),
                                            @"relayip":data[@"relayip"],
                                            @"relayport":data[@"relayport"],
                                            @"srcssid" :@([data[@"sessionid"]integerValue]+1),
                                            @"destssid": data[@"sessionid"],
                                            @"destaccount":[[self hostInfo] objectForKey:@"itel"],
                                            @"srcaccount" : data[@"destaccount"],
                                            @"peerNATType": @(selfNatType),
                                            @"useVideo"   : @([self.useVideo boolValue]),
                                            @"bakport"    : data[@"bakport"],
                                            }];
    NSDictionary *callingAuth=@{
                                kHead:@{
                                        kType: [NSNumber numberWithInt:SESSION_PERIOD_REQ_TYPE],
                                        kStatus:[NSNumber numberWithInt:NORMAL_STATUS],
                                        kSeq:[NSNumber numberWithInteger:[self.socketConnector seq]]
                                        },
                                kBody:@{
                                        kDestAccount:[callingData valueForKey:kSrcAccount],
                                        kData:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:callingData options:0 error:nil]  encoding:NSUTF8StringEncoding],
                                        kDataType:[NSNumber numberWithInt:EDT_SIGNEL]
                                        }
                                
                                };
    self.SSID=[[callingData objectForKey:@"destssid"] longValue];
    [self.socketConnector sendRequest:callingAuth type:[callingAuth[@"head"][@"type"]integerValue]];
}
#pragma mark - 主叫方收到被叫回复
-(void)callingResponse:(NSDictionary*)data{
    
    self.sessionState=@"对方已经接听,正在初始化通信通道...";
    NSLog(@"收到被叫方回复：%@",data);
    long receivedSSID =
    [[data valueForKey:@"srcssid"] longValue];
    
    if (receivedSSID==self.SSID) {
   
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(startTransportAndNotify:)
         name:P2PTUNNEL_SUCCESS
         object:nil];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(transportFailed:)
         name:P2PTUNNEL_FAILED
         object:nil];

        
       NSDictionary *info=[data mutableCopy];
        [info setValue:self.useVideo
                                  forKey:kUseVideo];
        if (![self.avSdk isP2PFinished]) {
            return;
        }
    
    
    
        [self.avSdk tunnelWith:info];
        
    } else {
       NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< "
              "主叫方收到非成对的ssid通话应答");
        }
}
// 被叫接听回掉
- (void)startTransportAndNotify:(NSNotification *)notify {
    
 
    self.sessionType=@(IMsessionTypeInSession);
     self.sessionState=@"开始通话";
    //进入通话状态
    
    [self.avSdk startTransport];

    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (void)transportFailed:(NSNotification *)notify {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
  
    
    
}

-(NSDictionary*)hostInfo{
    MaoAppDelegate *delegate=[UIApplication sharedApplication].delegate;
    return delegate.loginInfo;
}

-(int)openScreen:(UIView*)view{
    return [self.avSdk openScreen:view];
}













@end
