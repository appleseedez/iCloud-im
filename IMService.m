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
                     userInfo:data];
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
                    [self peerCallCome:bodySection];
                    break;
                case SESSION_PERIOD_ANSWERING_TYPE:
                    [self callingResponse:bodySection];
                    break;
                case CMID_APP_LOGIN_SSS_RESP_TYPE: //信令服务器验证响应返回了，通知业务层
                    NSLog(@"CMID_APP_LOGIN_SSS_RESP_TYPE");
                    break;
                case SESSION_PERIOD_HALT_TYPE:
                    NSLog(@"SESSION_PERIOD_HALT_TYPE");
                    [self endSession];
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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkFail:) name:SIGNAL_ERROR_NOTIFICATION object:nil];
    //构造通话信令
    self.peerAccount=peerItel;
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
-(void)checkFail:(NSNotification*)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SIGNAL_ERROR_NOTIFICATION object:nil];
    NSString *info=[notification.userInfo valueForKeyPath:@"body.description"];
    self.sessionState=[NSString stringWithFormat:@"%@",info];
    [self performSelector:@selector(endSession) withObject:nil afterDelay:2];
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
#pragma mark - 来电
-(void)peerCallCome:(NSDictionary*)data{
    if ([self.sessionType integerValue]!=IMsessionTypeEdle) {
        NSLog(@"正在通话中 拒绝来电%@",[data objectForKey:kDestAccount]);
        return;
    }
    self.peerAccount=[data objectForKey:kDestAccount];
    self.peerCallingData=data;
    self.useVideo=[data objectForKey:@"useVideo"];
    self.sessionType=@(IMsessionTypeAnsering);
   
}
static bool answering=NO;
-(void)answer:(BOOL)useVideo{
    if (answering==YES) {
        NSLog(@"answer 方法被多次调用");
        return;
    }
    
    answering=YES;
    self.useVideo=@(useVideo);
    [self.avSdk initNetwork];
    if ([self.useVideo boolValue]) {
        [self.avSdk openCamera];
    }
    NSDictionary *data=self.peerCallingData;
    //  获取本机的链路列表. 中继服务器目前充当外网地址探测
    NSDictionary *address=(NSDictionary*)[self.avSdk endPointAddressWithProbeServer:data[@"relayip"] port:[data[@"relayport"]integerValue] bakPort:[data[@"bakport"] integerValue]];
    NSLog(@"本地外网地址:%@",address);
       // 6. 把数据组装准备发送.
    //此处我需要做的是字典的数据融合！！！
    NSMutableDictionary *mergeData = [address mutableCopy];
    
    //将信令服务器返回的通话查询请求的响应中的转发地址和目的号码取出来，合并进新的通话请求信令中
    //总是在传递是以接收方的角po度去思
    //由于信令是发给对方的。所以destAccount和srcaccount应该是从对方的角度去思考。因此destAccount填的是自己的帐号，srcaccount填写的是对方的帐号。这样，在对方看来就是完美的。而且，对等方在构造信令数据时有相同的逻辑考
    
   
    
    [mergeData addEntriesFromDictionary:
     @{
       kType : @(SESSION_PERIOD_ANSWERING_TYPE),
       kRelayIP : [self.peerCallingData valueForKey:kRelayIP],
       kRelayPort : [self.peerCallingData valueForKey:kRelayPort],
       kDestSSID :  @([[self.peerCallingData valueForKey:kSrcSSID]intValue]+1),
       kSrcSSID : [self.peerCallingData valueForKey:kSrcSSID],
       kDestAccount : [[self hostInfo] objectForKey:@"itel"],
       kSrcAccount : [self.peerCallingData valueForKey:kDestAccount],
       kPeerNATType :@([self.avSdk currentNATType]),
       kUseVideo : [NSNumber numberWithBool:YES],
       kBakPort : [self.peerCallingData valueForKey:kBakPort]
       }];
    NSDictionary* result = @{
                             kHead:@{
                                     kType: [NSNumber numberWithInt:SESSION_PERIOD_REQ_TYPE],
                                     kStatus:[NSNumber numberWithInt:NORMAL_STATUS],
                                     kSeq:[NSNumber numberWithInteger:[self.socketConnector seq]]
                                     },
                             kBody:@{
                                     kDestAccount:[mergeData valueForKey:kSrcAccount],
                                     kData:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:mergeData options:0 error:nil]  encoding:NSUTF8StringEncoding],
                                     kDataType:[NSNumber numberWithInt:EDT_SIGNEL]
                                     
                                     }
                             
                             };
    [self.socketConnector sendRequest:result type:SESSION_PERIOD_REQ_TYPE];
    NSDictionary *info=[mergeData mutableCopy];
    [info setValue:[self.peerCallingData objectForKey:kPeerInterIP] forKey:kPeerInterIP];
    [info setValue:[self.peerCallingData objectForKey:kPeerLocalIP] forKey:kPeerLocalIP];
    [info setValue:[self.peerCallingData objectForKey:@"peerInterPort"] forKey:@"peerInterPort"];
    [info setValue:[self.peerCallingData objectForKey:kPeerLocalPort] forKey:kPeerLocalPort];
    [info setValue:@([[self.peerCallingData objectForKey:kSrcSSID]intValue]+1) forKey:kSrcSSID];
    [info setValue:[self.peerCallingData objectForKey:kSrcSSID] forKey:kDestSSID];
    [info setValue:[self.peerCallingData objectForKey:kPeerNATType] forKey:kPeerNATType];
    
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
    
    if (![self.avSdk isP2PFinished]) {
        return;
    }
    
    
    
    [self.avSdk tunnelWith:info];
    answering=NO;
}
#pragma mark - 挂断
-(void)haltSession:(NSString*)haltType{
    NSDictionary *params = @{
                             kType : [NSNumber numberWithInteger:SESSION_PERIOD_HALT_TYPE],
                             kSrcAccount : self.peerAccount,
                             kDestAccount : [[self hostInfo] objectForKey:@"itel"],
                             kHaltType : haltType
                             };
    NSDictionary* result = @{
                             kHead:@{
                                     kType: [NSNumber numberWithInt:SESSION_PERIOD_REQ_TYPE],
                                     kStatus:[NSNumber numberWithInt:NORMAL_STATUS],
                                     kSeq:[NSNumber numberWithInteger:[self.socketConnector seq]]
                                     },
                             kBody:@{
                                     kDestAccount:[params valueForKey:kSrcAccount],
                                     kData:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil]  encoding:NSUTF8StringEncoding],
                                     kDataType:[NSNumber numberWithInt:EDT_SIGNEL]
                                     }
                             
                             };
    
    [self.socketConnector sendRequest:result type:SESSION_PERIOD_REQ_TYPE];
   
    [self endSession];
}
-(void)endSession{
 
        [self.avSdk stopTransport];
    
    if (![self.avSdk isP2PFinished]) {
        [self.avSdk stopDetectP2P];
    }
    self.sessionType=@(IMsessionTypeEdle);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"endSession" object:nil userInfo:nil];
    //[self.avSdk tearDown];
}
-(NSDictionary*)hostInfo{
    MaoAppDelegate *delegate=[UIApplication sharedApplication].delegate;
    return delegate.loginInfo;
}

-(int)openScreen:(UIView*)view{
    int ret= [self.avSdk openScreen:view];
    
    NSLog(@"打开对方屏幕ret:%d",ret);
    
    return ret;
}













@end
