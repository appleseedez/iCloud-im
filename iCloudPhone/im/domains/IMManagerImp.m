//
//  IMManagerImp.m
//  iCloudPhone
//
//  Created by Pharaoh on 1/23/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import "IMManagerImp.h"
#import "IMTipImp.h"
#import "ConstantHeader.h"
#import "IMCoreDataManager.h"
#import "ItelAction.h"
#import "Recent+CRUD.h"
@interface IMManagerImp()
// state显示是一个信息收集的工具
@property (nonatomic) NSMutableDictionary* state;
@property (nonatomic,copy) NSString* selfAccount;
@property (nonatomic,strong) MSWeakTimer* keepSessionAlive;//从获取到外网地址，到收到通话回复。
@property (nonatomic) BOOL isVideoCall; //是否是视频通话

@property (nonatomic,strong) MSWeakTimer* communicationTimer; //用于进行通话时长计时
@property (nonatomic,strong) MSWeakTimer* monitor; //用于监控状态
@property (nonatomic) double duration; //通话时长
@property (nonatomic) int lossCount; //统计出现丢包的次数。 连续次数超过20 则自动挂断。
@property (nonatomic) int cameraIndex;
@property (nonatomic) NSNumber* basicState; // 基本状态值
@property (nonatomic) BOOL busy; //是否忙 KVO里直接根据basicState来自动设置是否忙
@property (nonatomic) NSNumber* isInP2P; //当前是否正在p2p中
@property (nonatomic) NSDictionary* recentLog; //作为最近通话记录的status字段
@property(nonatomic) BOOL deviceAuthorized;
@end
enum BasicStates
{
    basicStateIdle  = 0, //空闲
    basicStateQuering,// 查询对方在线
    basicStateCalling,// 拨打中
    basicStateAnswering,// 接听中
    basicStateInSession //通话中
    
};

@implementation IMManagerImp
static void* basicStateIndentifer = (void*)&basicStateIndentifer;
static void* p2pIndentifer = (void*)&p2pIndentifer;
static int hasObserver = 0;
#pragma mark - bussiness
- (BOOL)sessionStartedWithAccount:(NSString *)destAccount{
    return YES;
}
- (void)dial:(NSString *)account{
    // 从空闲进入查询
    if ([self.basicState intValue]  == basicStateIdle && [self canBeCalled:account]) {
        self.basicState =@(basicStateQuering);
#if usertip
        [[IMTipImp defaultTip] showTip:@"拨号中..."];
#endif
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>当前状态:%@,BUSY?:%d<<<<<<<<<<<<<<<<<<<<<<<<<<",[self describeState:self.basicState],self.busy);
#if DEBUG
        [[IMTipImp defaultTip] showTip:[self describeState:self.basicState]];
#endif
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInited:) name:SESSION_INITED_NOTIFICATION object:nil];
        //2.2 注册查询失败通知.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInitFail:) name:SIGNAL_ERROR_NOTIFICATION object:nil];
        //2.3 构造通话查询信令
        self.messageBuilder = [[IMSessionInitMessageBuilder alloc] init];
        NSDictionary* data = [self.messageBuilder buildWithParams:@{kDestAccount: account}];
#if SIGNAL_MESSAGE
        NSLog(@"发起通话查询请求：%@",data);
#endif
        //2.4 发送信令数据到信令服务器
        [self.TCPcommunicator send:data];
        //2.5 开启一个1.5秒的定时器,监视信令业务服务器的查询返回情况,如果在这个时间内都没有返回.则主叫方主动挂断
        [self.monitor invalidate];
        self.monitor = [MSWeakTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(haltCallingProgress) userInfo:nil repeats:NO dispatchQueue:dispatch_queue_create("com.itelland.monitor_queue", DISPATCH_QUEUE_CONCURRENT)];
    }else{
#if usertip
        [[IMTipImp defaultTip] showTip:@"本机正处于拨打状态.请稍后重试"];
#endif
    }
}

//如果超时未收到信令业务服务器的通话查询回复.则终止流程(通过终止接收信令服务器的通话查询返回.
- (void) haltCallingProgress{
    // 状态回到空闲
    [self assertState:basicStateQuering];
    self.basicState = @(basicStateIdle);
    //TODO 在状态回到空闲时,释放资源
    //提示用户
    dispatch_async(dispatch_get_main_queue(), ^{
#if usertip
        [[IMTipImp defaultTip] showTip:@"对方不在线,请稍后重试"];
#endif
    });
}
/**
 *  通话拒绝
 *  只是做信令数据的构造和发送
 */

-(void) sessionHaltRequest:(NSDictionary*) refuseData{
    //停止可能的保持session的包定时器
    [self.keepSessionAlive invalidate];
    self.keepSessionAlive = nil;
    // 处理参数
    NSDictionary* params = @{
                             kType:[NSNumber numberWithInteger:SESSION_PERIOD_HALT_TYPE],
                             kSrcAccount:[refuseData valueForKey:kDestAccount],
                             kDestAccount:[refuseData valueForKey:kSrcAccount],
                             kHaltType:[refuseData valueForKey:kHaltType]
                             };
    NSLog(@"准备发送的终止信令：%@",params);
    self.messageBuilder = [[IMSessionRefuseMessageBuilder alloc] init];
    NSDictionary* data =  [self.messageBuilder buildWithParams:params];
    [self.TCPcommunicator send:data];
    
    
}


// 终止当前的通话
- (void)haltSession:(NSDictionary*) data{
    if ([[data valueForKey:kHaltType] isEqualToString:kRefuseSession]) {
        self.recentLog = @{
                           kStatus:STATUS_REFUSED,
                           kPeerNumber:[data valueForKey:kDestAccount],
                           kCreateDate:[NSDate date]
                           };
    }

    [self sessionHaltRequest:data];
    [self endSession];
    [self saveCommnicationLog];
    //通知界面，关闭相应的视图
    [[NSNotificationCenter defaultCenter] postNotificationName:END_SESSION_NOTIFICATION object:nil userInfo:nil];
}


- (void)endSession{
     self.isInP2P = @(0);
    [self.monitor invalidate];
    [self.keepSessionAlive invalidate];
    //从非idle状态变回idle状态. 说明需要挂断. 给提示
#if usertip
    [[IMTipImp defaultTip] showTip:@"挂断中..."];
#endif
    
    [self stopCommunicationCounting];
    
    
    [self restoreState];
    self.basicState = @(basicStateIdle);
    [self.engine stopTransport];
//    [self.engine tearDown];
    [self performSelector:@selector(notifyInterfaceToEndSession) withObject:nil afterDelay:0];
}

//结束本次通话计时
- (void) stopCommunicationCounting{
    if (self.communicationTimer) {
        [self.communicationTimer invalidate];
        self.communicationTimer = nil;
    }
    
}
#pragma mark - callbacks
//通话查询请求成功
- (void) sessionInited:(NSNotification*) notify{
    [self assertState:basicStateQuering];
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SESSION_INITED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SIGNAL_ERROR_NOTIFICATION object:nil];

    //1. 终止掉超时定时器.这样,后续流程才能进行下去.
    [self.monitor invalidate];
    self.monitor = nil;

    //3.通话查询已经成功返回. 将本机的state设置成为接收到的信息
    // peerAccount
    [self.state setValue:[notify.userInfo valueForKey:kDestAccount] forKey:kPeerAccount];
    // myAccount
    [self.state setValue:[self myAccount] forKey:kMyAccount];
    // mySSID
    [self.state setValue:[notify.userInfo valueForKey:kSessionID] forKey:kMySSID];
    // peerSSID
    [self.state setValue:[NSNumber numberWithInteger:[[notify.userInfo valueForKey:kSessionID] integerValue]+1] forKey:kPeerSSID];
    // 转发ip
    [self.state setValue:[notify.userInfo valueForKey:kRelayIP] forKey:kForwardIP];
    // 转发port
    [self.state setValue: [notify.userInfo valueForKey:kRelayPort] forKey:kForwardPort];
    //4. 通知界面弹起拨号中界面 信息从manager.state里面取状态 不再通过通知传递了 接收通知的结果就是主叫方会弹出正在拨号界面
    [[NSNotificationCenter defaultCenter] postNotificationName:PRESENT_CALLING_VIEW_NOTIFICATION object:nil userInfo:nil];

    
    


    //6. 设置40秒超时，如果没有收到接受通话的回复则转到拒绝流程
    [self.monitor invalidate];
    self.monitor = [MSWeakTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(notPickup) userInfo:nil repeats:NO dispatchQueue:dispatch_queue_create("com.itelland.monitor_peer_pickup_queue", DISPATCH_QUEUE_CONCURRENT)];
    //主叫方组装通信链路数据,发送给peer 不再需要传递数据.直接从manager.state里面去取
    [self sendCallingData];
}

//通话查询请求失败
- (void) sessionInitFail:(NSNotification*) notify{
    [self assertState:basicStateQuering];
    
    self.basicState = @(basicStateIdle);
    //终止掉超时定时器.这样,后续流程才能进行下去.
    [self.monitor invalidate];
    self.monitor = nil;
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SESSION_INITED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SIGNAL_ERROR_NOTIFICATION object:nil];
    //对方是不是我好友
    if (![[ItelAction action] userInFriendBook:[self.state valueForKey:kPeerAccount]]) {
        // 提示用户 陌生人或者不存在的号码
#if usertip
        [[IMTipImp defaultTip] warningTip:@"对方不在线或者账号不存在"];
#endif
    }else{
#if usertip
        [[IMTipImp defaultTip] warningTip:@"好友不在线"];
#endif
    }
    //查询失败了.终止session
//    [self endSession];
//
}

// 主叫方收到了的应答
- (void) answeringDataDidReceived:(NSNotification*) answeringData{
    long receivedSSID = [[answeringData.userInfo valueForKey:@"srcssid"] longValue];
    long mySSID = [[[self myState] valueForKey:kMySSID] longValue];
    if (self.busy && receivedSSID == mySSID) {
        [self.monitor invalidate];
        //开始获取p2p通道，保持session的数据包可以停止发送了。
        [self.keepSessionAlive invalidate];
        self.keepSessionAlive = nil;
        //停止主叫方的超时定时器
        [self.monitor invalidate];
        self.monitor = nil;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startTransportAndNotify:) name:P2PTUNNEL_SUCCESS object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transportFailed:) name:P2PTUNNEL_FAILED object:nil];
        //告诉引擎，目前是否是视频通话
        [self setIsVideoCall: [[answeringData.userInfo valueForKey:kUseVideo] boolValue]&&self.canVideo&&self.isVideoCall];
        [answeringData.userInfo setValue:[NSNumber numberWithBool:self.isVideoCall] forKey:kUseVideo];
        self.isInP2P = @(1);
        NSLog(@"主叫收到应答时,传递给引擎的穿透数据:%@",answeringData.userInfo);
        [self.engine tunnelWith:answeringData.userInfo];

    }else{
        
        NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 主叫方收到非成对的ssid通话应答");
        [self sessionHaltRequest:@{
                            kType:[NSNumber numberWithInteger:SESSION_PERIOD_HALT_TYPE],
                            kSrcAccount:[[self myState] valueForKey:kMyAccount],
                            kDestAccount:[answeringData.userInfo valueForKey:kDestAccount],
                            kHaltType:kBusy
                            }];
    }
    

}
// 被叫方收到了请求
- (void) callingDataDidCame:(NSNotification*) callingData{
    if (self.busy) {
        NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 被叫方忙,收到通话请求");
        [self sessionHaltRequest:@{
                             kType:[NSNumber numberWithInteger:SESSION_PERIOD_HALT_TYPE],
                             kSrcAccount:[[self myState] valueForKey:kMyAccount],
                             kDestAccount:[callingData.userInfo valueForKey:kDestAccount],
                             kHaltType:kBusy
                             }];
        return;
    }else if([[ItelAction action] userInBlackBook:[callingData.userInfo valueForKey:kDestAccount]]){
        [self sessionHaltRequest:@{
                                   kType:[NSNumber numberWithInteger:SESSION_PERIOD_HALT_TYPE],
                                   kSrcAccount:[[self myState] valueForKey:kMyAccount],
                                   kDestAccount:[callingData.userInfo valueForKey:kDestAccount],
                                   kHaltType:kRefuseSession
                                   }];
        return;
    }
    [self.monitor invalidate];
    // 是否是
    //根据收到的usevideo和自身是否支持视频 设置自己是否有视频选项
    [self setIsVideoCall: [[callingData.userInfo valueForKey:kUseVideo] boolValue]&&self.canVideo];
    [callingData.userInfo setValue:[NSNumber numberWithBool:self.isVideoCall] forKey:kUseVideo];
    self.basicState = @(basicStateAnswering);
    //通知界面,弹出接听界面
    [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_PERIOD_REQ_NOTIFICATION object:Nil userInfo:callingData.userInfo];
}
//收到了对方的挂断消息
- (void) sessionHaltDataDidCome:(NSNotification* ) peerHaltData{
    //如果是忙碌状态. 发送endSession消息
    if (self.busy &&
        [[peerHaltData.userInfo valueForKey:kSrcAccount] isEqualToString:self.myAccount]){
        //做相关处理
        [self.keepSessionAlive invalidate];
        self.keepSessionAlive = nil;
        //收到拒绝也应该终止超时定时器
        [self.monitor invalidate];
        self.monitor = nil;
        NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 收到挂断");
        NSString* haltType = [peerHaltData.userInfo valueForKey:kHaltType];
        if ([kBusy isEqualToString:haltType]) {
            [self endSession];
        }else if ([kRefuseSession isEqualToString:haltType]){
            self.recentLog = @{
                               kStatus:STATUS_REFUSED,
                               kPeerNumber:[peerHaltData.userInfo valueForKey:kDestAccount],
                               kCreateDate:[NSDate date]
                               };
            
            [self endSession];
            [self saveCommnicationLog];
        }else if ([kEndSession isEqualToString:haltType]){
            //        [self.engine stopTransport];
            [self endSession];
            [self saveCommnicationLog];
        }else{
            //
        }
        
        [self performSelector:@selector(notifyInterfaceToEndSession) withObject:nil afterDelay:1];
    }

    
}

- (void) notifyInterfaceToEndSession{
    [[NSNotificationCenter defaultCenter] postNotificationName:END_SESSION_NOTIFICATION object:nil userInfo:nil];
}
// 收到服务器认证的返回值
- (void) authHasResult:(NSNotification*) result{
#if MANAGER_DEBUG
    NSLog(@"收到信令服务器端帐号验证响应~");
#endif
#if SIGNAL_MESSAGE
    NSLog(@"信令服务器的验证响应：%@",result.userInfo);
#endif
}

//被踢下线了
- (void) droppedFromSignal:(NSNotification*) notify{
#if OTHER_MESSAGE
    NSLog(@"我被踢下线了!!!!!!!");
#endif
    //当前用户被其他用此账号登陆的客户端踢下线了. 断开连接.提示当前用户,然后登出.
    
    // TODO: 被踢下线和是否在拨打状态有关系吗?!
    if (![[self.state valueForKey:kPeerAccount ]isEqualToString: IDLE]) {
        [self endSession];
        [self saveCommnicationLog];
    }
    
    [self tearDown];
    //提示用户
    UIAlertView* multiLoginAlert = [[UIAlertView alloc] initWithTitle:@"被踢下线通知" message:@"您的账号已在别处登陆.如果不是您本人操作,那么账号有可能被盗.请联系客服." delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
    [multiLoginAlert show];
    
}
// 从信令服务器注销
- (void)logoutFromSignalServer{
    self.messageBuilder = [IMLogoutFromSignalServerMessageBuilder new];
    NSDictionary* data = [self.messageBuilder
                          buildWithParams:@{
                                            kAccount: [self myAccount]
                                            }];
#if SIGNAL_MESSAGE
    NSLog(@"信令服务器的注销请求：%@",data);
#endif
    [self.TCPcommunicator send:data];
}
- (void) connectToSignalServer:(NSNotification*) signalServerData{
    //设置长连接地址
    NSDictionary* addressData = signalServerData.userInfo;
    [self.TCPcommunicator setupIP: [[addressData valueForKey:kBody] valueForKey:kIP]];
    [self.TCPcommunicator setupPort:[[[addressData valueForKey:kBody] valueForKey:kPort] intValue]];
    [self restoreState];
    
    //连接信令服务器
    [self.TCPcommunicator connect:[self myAccount] withAuthInfo: [self authInfoWith:self.selfAccount cert:@"chengjianjun"]];
    [self.TCPcommunicator keepAlive];
#if MANAGER_DEBUG
    NSLog(@"目前的本机帐号：%@",[self myAccount]);
#endif
}
#pragma mark - KVO callback
//做基本状态的监听.如果状态发生改变
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == basicStateIndentifer) {
        NSNumber* newState =(NSNumber*) [change valueForKey:@"new"];
        if ([newState intValue] != basicStateIdle) {
            self.busy = YES;
        }
    }
    if (context == p2pIndentifer) {
        NSNumber * newP2PState = (NSNumber*)[change valueForKey:@"new"];
        if ([newP2PState intValue] != 0) {
            self.busy = YES;
        }
    }
    
    if ([self.basicState intValue] == basicStateIdle && [self.isInP2P intValue] == 0 ) {
        self.busy = NO;
    }
}

#pragma mark - private
//判断账号是否可以拨打
- (BOOL) canBeCalled:(NSString*) account{
    if ([account isEqualToString:BLANK_STRING] ||[account isEqualToString:[self myAccount]]) {
        return NO;
    }
    return YES;
}
- (NSString*) describeState:(NSNumber*) state{
    NSString* describeString = BLANK_STRING;
    int basicState = [state intValue];
    switch (basicState) {
        case basicStateIdle:
            describeString = @"当前basicState:空闲";
            break;
        case basicStateQuering:
            describeString = @"当前basicState:查询中";
            break;
        case basicStateCalling:
            describeString = @"当前basicState:拨打中";
            break;
        case basicStateAnswering:
            describeString = @"当前basicState:接听中";
            break;
        case basicStateInSession:
            describeString = @"当前basicState:通话中";
            break;
        default:
            break;
    }
    return describeString;
}
// 通话查询成功后, 处理收到的数据.
- (void)queryDataProcess{
#if DEBUG
    [[IMTipImp defaultTip] showTip:@"处理收到的通话查询记录"];
#endif
}

- (void)sendCallingData{
#if DEBUG
    [[IMTipImp defaultTip] showTip:@"发送数据 主叫 >>> 被叫"];
#endif
    self.basicState = @(basicStateCalling);
    // 使用主叫通信链路信令构造器构造通信链路数据.
    self.messageBuilder = [[IMSessionPeriodRequestMessageBuilder alloc] init];
    [self sendSessionDataFor:[NSNumber numberWithInt:SESSION_PERIOD_CALLING_TYPE]];
}
- (void)sendAnsweringData{
#if DEBUG
    [[IMTipImp defaultTip] showTip:@"发送数据 主叫 <<< 被叫"];
#endif
    self.basicState = @(basicStateAnswering);
    // 使用主叫通信链路信令构造器构造通信链路数据.
    self.messageBuilder = [[IMSessionPeriodResponseMessageBuilder alloc] init];
    [self sendSessionDataFor:[NSNumber numberWithInt:SESSION_PERIOD_ANSWERING_TYPE]];
}

- (void) assertState:(int)expectState{
    NSString* reason = [NSString stringWithFormat:@"期望状态是:%@,但是实际上却是:%@",[self describeState: @(expectState)],[self describeState:self.basicState]];
    if ([self.basicState intValue] != expectState) {
#if DEBUG
        [[IMTipImp defaultTip] errorTip:[NSString stringWithFormat:@"%@",reason]];
#endif
    }
}


- (void) restoreState{
    self.state = [NSMutableDictionary dictionaryWithDictionary: @{
                                                                  kMyAccount:[self myAccount], // 登陆状况下的通话查询结束. 账号还是要的
                                                                  kMySSID:@(-1), //空闲
                                                                  kPeerAccount:IDLE, //空闲
                                                                  kPeerSSID:@(-1), //空闲
                                                                  kForwardIP:BLANK_STRING,
                                                                  kForwardPort:@(-1),
                                                                  kUseVideo:@(-1)
                                                                  }];
}


- (void) startCommunicationCounting{
    //状态归零
    [self.communicationTimer invalidate];
    self.duration = 0.0;
    self.lossCount = 0;
    self.communicationTimer = [MSWeakTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(durationTick) userInfo:nil repeats:YES dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
}

// 依赖注入
- (void)injectDependency {
    self.engine = [[IMEngineImp alloc] init];// 引擎
    self.TCPcommunicator = [[IMTCPCommunicator alloc] init];// 网络通信器
    self.UDPcommunicator = [[IMUDPCommunicator alloc] init];
}
//根据数据的具体类型做操作路由
- (void) route:(NSDictionary*) data{
    NSInteger type = -1;
    //具体的数据
    NSDictionary* bodySection = @{};
    // 以是否具有head块作为解析依据。
    
    // 获取头部数据
    NSDictionary* headSection = [data valueForKey:kHead];
    if (headSection) {
        type = [[headSection valueForKey:kType] integerValue];
        NSInteger status = [[headSection valueForKey:kStatus] integerValue];
        // 异常情况处理。
        if (status != NORMAL_STATUS) {
            [NSException exceptionWithName:@"500:data format error" reason:@"信令服务器返回数据状态不正常" userInfo:nil];
            //如果收到的status不正常, 则触发该消息
            [[NSNotificationCenter defaultCenter] postNotificationName:SIGNAL_ERROR_NOTIFICATION object:nil userInfo:@{kType:@(type)}];
            return;
        }
        bodySection = [data valueForKey:kBody];
    }else{
        type = [[data valueForKey:kType] integerValue];
        bodySection = data;
    }
    
    //路由
    switch (type) {
        case SESSION_INIT_RES_TYPE:
            // 通话查询请求正常返回，通知业务层
            // [self sessionInited:]
            [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_INITED_NOTIFICATION object:nil userInfo:bodySection];
            break;
        case SESSION_PERIOD_CALLING_TYPE:
            [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_PERIOD_CALLING_COME_NOTIFICATION object:nil userInfo:bodySection];
            break;
        case SESSION_PERIOD_ANSWERING_TYPE:
            [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_PERIOD_ANSWERING_COME_NOTIFICATION object:nil userInfo:bodySection];
            break;
        case CMID_APP_LOGIN_SSS_RESP_TYPE: //信令服务器验证响应返回了，通知业务层
            [[NSNotificationCenter defaultCenter] postNotificationName:CMID_APP_LOGIN_SSS_NOTIFICATION object:nil userInfo:bodySection];
            break;
        case SESSION_PERIOD_HALT_TYPE:
            [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_PERIOD_HALT_NOTIFICATION object:nil userInfo:bodySection];
            break;
        case CMID_APP_DROPPED_SSS_REQ_TYPE:
            [[NSNotificationCenter defaultCenter] postNotificationName:DROPPED_FROM_SIGNAL_NOTIFICATION object:nil userInfo:bodySection];
            break;
        default:
            break;
    }
    
}
// 向信令服务器做一次验证
- (NSDictionary*) authInfoWith:(NSString*) selfAccount
         cert:(NSString*) cert{
    NSString* token = BLANK_STRING; // 推送用到的token
    self.messageBuilder = [[IMAuthMessageBuilder alloc] init];
    return [self.messageBuilder buildWithParams:@{
                                                                kAccount:selfAccount,
                                                                kClientType:[NSNumber numberWithInt:ACT_IOS],
                                                                kClientStatus:[NSNumber numberWithInt:AST_ONLINE],
                                                                kToken:token
                                                                }];
}

// 信令回复数据的处理 采用通知来完成
- (void) receive:(NSNotification*) notify{
#if MANAGER_DEBUG
    NSLog(@"收到数据，路由给处理逻辑");
#endif
    [self route:notify.userInfo];
}
//在通话session结束时,停止通话计时.保存.
- (void) saveCommnicationLog{
    //如果recentLog为空,则不需要记录.因为只有在通信通道(p2p通道/转发通道)建立后才会有recentLog
    if (![self.recentLog valueForKey:kPeerNumber]) {
        return;
    }
    NSManagedObjectContext* currentContext =[[IMCoreDataManager defaulManager] managedObjectContext];
    ItelUser* peer =  [[ItelAction action] userInFriendBook:[self.recentLog valueForKey:kPeerNumber]];
    NSString* peerRemarkName = BLANK_STRING;
    NSString* peerNickName = BLANK_STRING;
    NSString* peerAvatar = BLANK_STRING;
    if (!peer) {
        peerRemarkName = @"陌生人";
        peerNickName = @"陌生人";
        peerAvatar  = @"";
    }else{
        peerRemarkName = peer.remarkName;
        peerNickName = peer.nickName;
        peerAvatar = peer.imageurl;
    }
    Recent* aRecent =  [Recent recentWithCallInfo:@{
                                                    kPeerNumber:[self.recentLog valueForKey:kPeerNumber],
                                                    kStatus:[self.recentLog valueForKey:kStatus],
                                                    kDuration:@(self.duration),
                                                    kCreateDate:[self.recentLog valueForKey:kCreateDate],
                                                    kPeerRealName:peerRemarkName,
                                                    kPeerNick:peerNickName,
                                                    kPeerAvatar:peerAvatar,
                                                    kHostUserNumber:self.myAccount
                                                    }
                                        inContext:currentContext];
    [[IMCoreDataManager defaulManager] saveContext:currentContext];
#if MANAGER_DEBUG
    NSLog(@"aRecent is :%@",aRecent);
#endif
    
    
    
}

- (void)checkDeviceAuthorizationStatus
{
	NSString *mediaType = AVMediaTypeVideo;
	
	[AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
		if (granted)
		{
			//Granted access to mediaType
			[self setDeviceAuthorized:YES];
		}
		else
		{
			//Not granted access to mediaType
			dispatch_async(dispatch_get_main_queue(), ^{
				[[[UIAlertView alloc] initWithTitle:@"iTel"
											message:@"如果不开启摄像头和mic权限,将无法使用视频及音频功能"
										   delegate:self
								  cancelButtonTitle:@"我知道了"
								  otherButtonTitles:nil] show];
				[self setDeviceAuthorized:NO];
			});
		}
	}];
}
#pragma mark - life cycle

- (void)setup{
    self.basicState = @(basicStateIdle);
    self.isInP2P  = @(0);
    [self registerNotifications];
    [self checkDeviceAuthorizationStatus];
    [self injectDependency];
    [self.engine initMedia];
    //监视basicState的状态改变.
    if (hasObserver == 0) {
        [self addObserver:self forKeyPath:@"basicState" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&basicStateIndentifer];
        [self addObserver:self forKeyPath:@"isInP2P" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&p2pIndentifer];
        hasObserver = 1;
    }


}
- (void) tearDown{
    self.basicState = @(basicStateIdle);
    self.isInP2P = @(0);
    if (hasObserver == 1) {
        [self removeObserver:self forKeyPath:@"basicState" context:&basicStateIndentifer];
        [self removeObserver:self forKeyPath:@"isInP2P" context:&p2pIndentifer];
        hasObserver = 0;
    }
    //保存所有修改
    //TODO: 断线时保存修改
    //从业务服务器断开
    [self disconnectToSignalServer];
    //销毁引擎
    [self.engine tearDown];
    self.engine = nil;
    //销毁tcp连接器
    [self.TCPcommunicator tearDown];
    self.TCPcommunicator =  nil;
    //销毁udp连接器
    [self.UDPcommunicator tearDown];
    self.UDPcommunicator = nil;
    //信令构造器销毁
    self.messageBuilder = nil;

}

- (void) connectToSignalServer{
#if MANAGER_DEBUG
    NSLog(@"开始连接信令服务器");
#endif
    //注册事件
    [self registerNotifications];
    //连接信令服务器
#if SIGNAL_MESSAGE
    NSLog(@"当前的routeIP:%@",self.routeIP);
#endif
    [self.UDPcommunicator setupIP:self.routeIP];
    [self.UDPcommunicator setupPort:self.port];
    if(self.selfAccount == nil){
#if usertip
        [[IMTipImp defaultTip] errorTip:@"用户帐号信息为空"];
#endif
    }
    [self.UDPcommunicator connect:[self myAccount]];
}

- (void) disconnectToSignalServer{
    [self.TCPcommunicator disconnect];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//被叫方接受了本次通话请求
- (void) acceptSession:(NSNotification*) notify{
    [self assertState:basicStateAnswering];
    //获取p2p任务盒子
    [self restoreState];
    // 将收到的对方链路列表中的数据提取出来.
    // 被叫方开始获取自己的外网ip等等链路信息
    [self.state setValue:[notify.userInfo valueForKey:kSrcSSID] forKey:kMySSID];
    [self.state setValue:[notify.userInfo valueForKey:kDestSSID] forKey:kPeerSSID];
    [self.state setValue:[notify.userInfo valueForKey:kRelayIP] forKey:kForwardIP];
    [self.state setValue:[notify.userInfo valueForKey:kRelayPort] forKey:kForwardPort];
    [self.state setValue:[notify.userInfo valueForKey:kDestAccount] forKey:kPeerAccount];
    //被叫方发送链路数据给主叫方
    [self sendAnsweringData];
    // 开始获取p2p通道
    [self.keepSessionAlive invalidate];
    self.keepSessionAlive = nil;
#if MANAGER_DEBUG
    NSLog(@"接受通话请求，停止session保持数据包的发送，开始获取p2p通道");
#endif
    //用于接收通道建立成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(justStartTransport:) name:P2PTUNNEL_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transportFailed:) name:P2PTUNNEL_FAILED object:nil];
    //开始建立通道
    self.isInP2P = @(1);
    NSLog(@"被叫接受请求时,传递给引擎的穿透数据:%@",notify.userInfo);
    [self.engine tunnelWith:notify.userInfo];
}
/**
 *  主叫,被叫方都通过这个方法发送链路列表数据
 *
 *  @param peerType 主叫方发送:SESSION_PERIOD_PROCEED_TYPE 被叫方发送:SESSION_PERIOD_ANSWERING_TYPE
 */
- (void) sendSessionDataFor:(NSNumber*) peerType{

    // 2. 记录当前是准备和对方视频通话还是音频通话
    [self.state setValue:[NSNumber numberWithBool:self.isVideoCall&&self.canVideo] forKey:kUseVideo];
    if ([[self.state valueForKey:kUseVideo] boolValue]){
       BOOL ret =  [self.engine openCamera];
        [self.state setValue:[NSNumber numberWithBool:ret] forKey:kUseVideo];
    }
    //主叫和被叫都在发送数据之前初始化网络. 等待即将到来的p2p数据
    [self.engine initNetwork];
    // 3.获取本机natType
    NatType natType = StunTypeBlocked;
    
    //4. 获取本机的链路列表. 中继服务器目前充当外网地址探测
    NSDictionary* communicationAddress = [self.engine endPointAddressWithProbeServer:[self.state valueForKey:kForwardIP] port:[[self.state valueForKey:kForwardPort] integerValue]];
    //5.获取到外网地址后，开始发送数据包到外网地址探测服务器，直到收到对等方的回复。
#if DEBUG
    [[IMTipImp defaultTip] showTip:@"开始进行保持外网session的数据包发送"];
#endif
    [self.keepSessionAlive invalidate];
    
    
    self.keepSessionAlive = [MSWeakTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(keepSession:) userInfo:@{PROBE_PORT_KEY:[self.state valueForKey:kForwardPort],PROBE_SERVER_KEY:[self.state valueForKey:kForwardIP]} repeats:YES dispatchQueue:dispatch_queue_create("com.itelland.keepIPSession", DISPATCH_QUEUE_CONCURRENT)];
    // 6. 把数据组装准备发送.
    //此处我需要做的是字典的数据融合！！！
    NSMutableDictionary* mergeData = [communicationAddress mutableCopy];
    
    //将信令服务器返回的通话查询请求的响应中的转发地址和目的号码取出来，合并进新的通话请求信令中
    //总是在传递是以接收方的角度去思
    //由于信令是发给对方的。所以destAccount和srcaccount应该是从对方的角度去思考。因此destAccount填的是自己的帐号，srcaccount填写的是对方的帐号。这样，在对方看来就是完美的。而且，对等方在构造信令数据时有相同的逻辑考
    
    [mergeData addEntriesFromDictionary:@{
                                          kType:peerType,
                                          kRelayIP:
                                              [self.state valueForKey:kForwardIP],
                                          kRelayPort:
                                              [self.state valueForKey:kForwardPort],
                                          kSrcSSID:[self.state valueForKey:kPeerSSID],
                                          kDestSSID:[self.state valueForKey:kMySSID],
                                          kDestAccount: self.selfAccount,
                                          kSrcAccount:[self.state valueForKey:kPeerAccount],
                                          kPeerNATType: [NSNumber numberWithInt:natType],
                                          kUseVideo:[self.state valueForKey:kUseVideo]
                                          }];
    
    
    
    // 构造通话数据请求
    NSDictionary* data = [self.messageBuilder buildWithParams:mergeData];
#if SIGNAL_MESSAGE
    NSLog(@"[账号:%@] >>>> [账号:%@] \n %@",[self.state valueForKey:kMyAccount],[self.state valueForKey:kPeerAccount],data);
#endif
    
    
    //8. 发送通信所需的数据
    [self.TCPcommunicator send:data];
}

- (void) registerNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectToSignalServer:) name:UDP_LOOKUP_COMPLETE_NOTIFICATION object:nil];
    //网络通信器会在收到数据响应时，发出该通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receive:) name:DATA_RECEIVED_NOTIFICATION object:nil];
    //有通话请求到了 通知被叫接听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callingDataDidCame:) name:SESSION_PERIOD_CALLING_COME_NOTIFICATION object:nil];
    //有通话回复来了. 通知主叫接听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(answeringDataDidReceived:) name:SESSION_PERIOD_ANSWERING_COME_NOTIFICATION object:nil];
    //通话终止，发这个通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionHaltDataDidCome:) name:SESSION_PERIOD_HALT_NOTIFICATION object:nil];
    //登录到信令服务器后，需要做一次验证，验证信息响应时，发出该通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authHasResult:) name:CMID_APP_LOGIN_SSS_NOTIFICATION object:nil];
    
    //收到了被服务器踢下线通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(droppedFromSignal:) name:DROPPED_FROM_SIGNAL_NOTIFICATION object:nil];
}

/**
 *  注销用户时删除保存的本地数据
 */
- (void) clearTable{
    //删除所有表中的数据
    NSArray* tableNames = @[
                            @"HostItelUser",
                            @"Message",
                            @"ItelUser",
                            @"Recent"
                            
                            ];
    NSManagedObjectContext* currentContext = [IMCoreDataManager defaulManager].managedObjectContext;
    if (currentContext) {
        //从数组中获得表名.依次删除
        NSError* error;
        for (NSString* tableName in tableNames) {
            NSFetchRequest* clearTableRequest = [NSFetchRequest fetchRequestWithEntityName:tableName];
            NSArray* hostUsers = [currentContext executeFetchRequest:clearTableRequest error:&error];
            for (NSManagedObject* o in hostUsers) {
                [currentContext deleteObject:o];
            }
            
        }
        [[IMCoreDataManager defaulManager] saveContext:currentContext];
        
        
    }
    
    
}
#pragma mark -  actions
//保持外网ip有效的心跳方法
- (void) keepSession:(NSTimer*) timer{
#if DEBUG
    [[IMTipImp defaultTip] showTip:@"开始发送保持session的数据包"];
#endif
    NSDictionary* param = [timer userInfo];
    NSString* probeServerIP = [param valueForKey:PROBE_SERVER_KEY];
    NSInteger port = [[param valueForKey:PROBE_PORT_KEY] integerValue];
    [self.engine keepSessionAlive:probeServerIP port:port];
}
// 被叫接听回掉
- (void) startTransportAndNotify:(NSNotification*) notify{
    self.isInP2P = @(0);
    //如果是空闲. 白穿透了.
    if ([self.basicState intValue] == basicStateIdle) {
        NSLog(@"主叫方P2P成功 但是状态是idle");
        return;
    }
    //进入通话状态
    self.basicState = @(basicStateInSession);
    [self.engine startTransport];
    //开始通话计时
    self.recentLog = @{
                       kStatus:STATUS_CALLED,
                       kPeerNumber:[notify.userInfo valueForKey:kDestAccount],
                       kCreateDate:[NSDate date]
                       };
#if OTHER_MESSAGE
    NSLog(@"the log to be saved : %@",self.recentLog);
#endif
    [self startCommunicationCounting];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:P2PTUNNEL_SUCCESS object:nil];
    //通知view可以切换的到“通话中"界面了
    [[NSNotificationCenter defaultCenter] postNotificationName:PRESENT_INSESSION_VIEW_NOTIFICATION
                                                        object:nil
                                                      userInfo:notify.userInfo];
}


//被叫方开启通道
- (void) justStartTransport:(NSNotification*) notify{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:P2PTUNNEL_SUCCESS object:nil];
    self.isInP2P =@(0);
    //如果是空闲. 白穿透了.
    if ([self.basicState intValue] == basicStateIdle) {
        NSLog(@"被叫方P2P成功 但是状态是idle");
        return;
    }
    //进入通话状态
    self.basicState = @(basicStateInSession);
    [self.engine startTransport];
    //开始通话计时
    self.recentLog = @{
                       kStatus:STATUS_ANSWERED,
                       kPeerNumber:[notify.userInfo valueForKey:kDestAccount],
                       kCreateDate:[NSDate date]
                       };
    
#if OTHER_MESSAGE
    NSLog(@"the log to be saved : %@",self.recentLog);
#endif
    [self startCommunicationCounting];

}
- (void) transportFailed:(NSNotification*) notify{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:P2PTUNNEL_FAILED object:nil];
    //还原p2p状态为0 这样才能让self.busy变成0
    self.isInP2P = @(0);
    [self endSession];
    [self saveCommnicationLog];
    //通知界面，关闭相应的视图
    [self performSelector:@selector(notifyInterfaceToEndSession) withObject:nil afterDelay:1];
//    [[NSNotificationCenter defaultCenter] postNotificationName:END_SESSION_NOTIFICATION object:nil userInfo:nil];
}

- (void) durationTick{
    self.duration++;
    //如果连续出现20次countTopSize为零，则终止通话
    if ([self.engine countTopSize]>0) {
        self.lossCount =0;
        return;
    }
    if (self.lossCount>=20) {
        [self haltSession:@{
                            kSrcAccount:[self myAccount],
                            kDestAccount:[self.state valueForKey:kPeerAccount],
                            kHaltType:kEndSession
                            }];
    }
    self.lossCount++;
#if DEBUG
    [[IMTipImp defaultTip] showTip:[NSString stringWithFormat:@"当前通话持续时间:%f,当前收到的数据长度:%d",self.duration,self.lossCount]];
#endif
}

// 没有接听 超时,发sessionend
- (void) notPickup{
    //停止定时器
    [self.monitor invalidate];
    self.monitor = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
#if usertip
        [[IMTipImp defaultTip] showTip:@"无人接听"];
#endif
    });
    //发送终止信令
    [self haltSession:@{
                        kSrcAccount:[self myAccount],
                        kDestAccount:[self.state valueForKey:kPeerAccount],
                        kHaltType:kEndSession
                        }];
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //通知系统,登出当前用户
    [[NSNotificationCenter defaultCenter] postNotificationName:@"signOut" object:nil userInfo:nil];
}
- (void)alertViewCancel:(UIAlertView *)alertView{
    alertView.delegate = nil;
}

#pragma mark - accessories

- (void)openScreen:(VideoRenderIosView *)remoteRenderView localView:(UIView *)localView{
    [self.engine openScreen:remoteRenderView localView:localView];
}
- (void)closeScreen{
}
- (void)lockScreenForSession{
    [UIApplication sharedApplication].idleTimerDisabled=YES;
}

- (void)unlockScreenForSession{
    [UIApplication sharedApplication].idleTimerDisabled=NO;
}

- (void)mute{
    [self.engine mute];
}
- (void)unmute{
    [self.engine unmute];
}
- (void)enableSpeaker{
    [self.engine enableSpeaker];
}
- (void)disableSpeaker{
    [self.engine disableSpeaker];
}
- (void)showCam{
    [self.engine showCam];
    
}
- (void)hideCam{
    [self.engine hideCam];
}
- (void)showSelfCam{
    
}
- (void)hideSelfCam{
    
}
- (void) doSwitchCam{
    
}
- (void)switchCamera{
    [self.engine switchCamera];
}
- (void)setMyAccount:(NSString *)account{
    if (!account) {
        self.selfAccount = BLANK_STRING;
    }
    
    self.selfAccount = account;
}
- (NSString *)myAccount{
    if (!self.selfAccount) {
        self.selfAccount = BLANK_STRING;
    }
    
    return self.selfAccount;
}
//synthesize的理解
@synthesize isVideoCall = _isVideoCall;
- (void) setIsVideoCall:(BOOL)isVideoCall{
    _isVideoCall = isVideoCall;
}
- (BOOL) isVideoCall{
    return _isVideoCall;
}
//检查是否可以视频
- (BOOL)canVideo{
    return [self.engine canVideoCalling];
}
- (void)setCanVideo:(BOOL)canVideo{
    [self.engine setCanVideoCalling:canVideo];
}
- (void)setRouteSeverIP:(NSString *)ip{
    self.routeIP = ip;
}
- (void)setRouteServerPort:(u_int16_t)port{
    self.port = port;
}

- (double)checkDuration{
    return self.duration;
}

- (NSDictionary *)myState{
    return self.state;
}
@end
