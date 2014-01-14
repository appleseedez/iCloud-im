//
//  IMManagerImp.m
//  im
//
//  Created by Pharaoh on 13-11-20.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import "IMManagerImp.h"
#import  "ConstantHeader.h"
#import "Recent.h"
#import "Recent+CRUD.h"
#import "ItelUser+CRUD.h"
#import "ItelAction.h"
#import "IMCoreDataManager.h"
@interface IMManagerImp ()

//状态标识符，表明当前所处的状态。目前只有占用和空闲两种 占用：目标itel号码， 空闲：IDLE
@property (nonatomic,copy) NSString* state;
@property (nonatomic,copy) NSString* selfAccount;
@property (nonatomic,strong) NSTimer* keepSessionAlive;//从获取到外网地址，到收到通话回复。
@property (nonatomic) BOOL isVideoCall; //是否是视频通话

@property (nonatomic,strong) MSWeakTimer* communicationTimer; //用于进行通话时长计时
@property (nonatomic,strong) MSWeakTimer* monitor; //用于监控状态
@property (nonatomic) double duration; //通话时长

@property (nonatomic) NSDictionary* recentLog; //作为最近通话记录的status字段
@end

@implementation IMManagerImp
#pragma mark - LOGIC

- (void) testSessionStart:(NSString*) destAccount{
    // 通话查询开始
    if ([self startSession:destAccount] == NO) {
        return;
    }
    //对收到的信令响应数据进行解析后，如果是通话查询请求的响应，则发出该通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInited:) name:SESSION_INITED_NOTIFICATION object:nil];
    // 构造通话查询信令
    self.messageBuilder = [[IMSessionInitMessageBuilder alloc] init];
    //通话查询请求数据的构造
    NSDictionary* data = [self.messageBuilder buildWithParams:@{SESSION_INIT_REQ_FIELD_DEST_ACCOUNT_KEY: destAccount}];
#if SIGNAL_MESSAGE
    NSLog(@"发起通话查询请求：%@",data);
#endif
    // 发送信令数据到信令服务器
    [self.TCPcommunicator send:data];
    //开启一个1.5秒的定时器,监视信令业务服务器的查询返回情况,如果在这个时间内都没有返回.则主叫方主动挂断
    [self.monitor invalidate];
    self.monitor = [MSWeakTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(haltCallingProgress) userInfo:nil repeats:NO dispatchQueue:dispatch_queue_create("com.itelland.monitor_queue", DISPATCH_QUEUE_CONCURRENT)];
    // 转到 [self receive:];
}
//如果超时未收到信令业务服务器的通话查询回复.则终止流程(通过终止接收信令服务器的通话查询返回.
- (void) haltCallingProgress{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SESSION_INITED_NOTIFICATION object:nil];
    [self endSession];
    //TODO:提示用户
}
// 向信令服务器做一次验证
- (void) auth:(NSString*) selfAccount
         cert:(NSString*) cert{
    NSString* token = BLANK_STRING; // 推送用到的token
    self.messageBuilder = [[IMAuthMessageBuilder alloc] init];
    NSDictionary* data = [self.messageBuilder buildWithParams:@{
                                                                CMID_APP_LOGIN_SSS_REQ_FIELD_ACCOUNT_KEY:selfAccount,
                                                                CMID_APP_LOGIN_SSS_REQ_FIELD_CLIENT_TYPE_KEY:[NSNumber numberWithInt:ACT_IOS],
                                                                CMID_APP_LOGIN_SSS_REQ_FIELD_CLIENT_STATUS_KEY:[NSNumber numberWithInt:AST_ONLINE],
                                                                CMID_APP_LOGIN_SSS_REQ_FIELD_TOKEN_KEY:token
                                                                }];
#if SIGNAL_MESSAGE
    NSLog(@"信令服务器的验证请求：%@",data);
#endif
    [self.TCPcommunicator send:data];
}

#pragma mark - PRIVATE

// 注册通知
- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectToSignalServer:) name:UDP_LOOKUP_COMPLETE_NOTIFICATION object:nil];
    //网络通信器会在收到数据响应时，发出该通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receive:) name:DATA_RECEIVED_NOTIFICATION object:nil];
//    //对收到的信令响应数据进行解析后，如果是通话查询请求的响应，则发出该通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInited:) name:SESSION_INITED_NOTIFICATION object:nil];
    //通话请求期间的数据通信，都发这个通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionPeriod:) name:SESSION_PERIOD_NOTIFICATION object:nil];
    //通话终止，发这个通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionHalt:) name:SESSION_PERIOD_HALT_NOTIFICATION object:nil];
    //登录到信令服务器后，需要做一次验证，验证信息响应时，发出该通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authHasResult:) name:CMID_APP_LOGIN_SSS_NOTIFICATION object:nil];
    // 收到异常信令
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInitFail:) name:SIGNAL_ERROR_NOTIFICATION object:nil];
    //收到了被服务器踢下线通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(droppedFromSignal:) name:DROPPED_FROM_SIGNAL_NOTIFICATION object:nil];
}

//移除通知 防止leak
- (void) removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 依赖注入
- (void)injectDependency {
    self.engine = [[IMEngineImp alloc] init];// 引擎
    self.TCPcommunicator = [[IMTCPCommunicator alloc] init];// 网络通信器
    self.messageParser = [[IMMessageParserImp alloc] init]; // 信令解析器
    self.UDPcommunicator = [[IMUDPCommunicator alloc] init];
}
//根据数据的具体类型做操作路由
- (void) route:(NSDictionary*) data{
    NSInteger type = -1;
    //具体的数据
    NSDictionary* bodySection = @{};
    // 以是否具有head块作为解析依据。
    
    // 获取头部数据
    NSDictionary* headSection = [data valueForKey:HEAD_SECTION_KEY];
    if (headSection) {
        type = [[headSection valueForKey:DATA_TYPE_KEY] integerValue];
        NSInteger status = [[headSection valueForKey:DATA_STATUS_KEY] integerValue];
        // 异常情况处理。
        if (status != NORMAL_STATUS) {
            [NSException exceptionWithName:@"500:data format error" reason:@"信令服务器返回数据状态不正常" userInfo:nil];
            //如果收到的status不正常, 则触发该消息
            [[NSNotificationCenter defaultCenter] postNotificationName:SIGNAL_ERROR_NOTIFICATION object:nil userInfo:@{DATA_TYPE_KEY:@(type)}];
            return;
        }
        bodySection = [data valueForKey:BODY_SECTION_KEY];
    }else{
        type = [[data valueForKey:DATA_TYPE_KEY] integerValue];
        bodySection = data;
    }
    
    //路由
    switch (type) {
        case SESSION_INIT_RES_TYPE:
            // 通话查询请求正常返回，通知业务层
            // [self sessionInited:]
            [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_INITED_NOTIFICATION object:nil userInfo:bodySection];
            break;
        case SESSION_PERIOD_PROCEED_TYPE:
            [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_PERIOD_NOTIFICATION object:nil userInfo:bodySection];
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
/**
 *  通话建立过程中的协议交换
 *
 *  封装了构造和发送通话请求和回复的过程。
 *  用过使用不同的信令构造器，就可以做到用一套逻辑处理请求和回复两种
 *
 *  @param void negotiationData 协议数据
 *
 *  @return void
 */
- (void) sessionPeriodNegotiation:(NSDictionary*) negotiationData{
    [self.engine initNetwork];
    NSDictionary* parsedData =  [self.messageParser parse:negotiationData];
#if MANAGER_DEBUG
    NSLog(@"获取到的谈判数据：%@",parsedData);
#endif
    NSString* forwardIP = [parsedData valueForKey:SESSION_INIT_RES_FIELD_FORWARD_IP_KEY];
    NSInteger forwardPort = [[parsedData valueForKey:SESSION_INIT_RES_FIELD_FORWARD_PORT_KEY] integerValue];
    // 获取本机natType
    NatType natType = [self.engine natType];
#if MANAGER_DEBUG
    NSLog(@"本机的NAT类型：%d",natType);
#endif
    // 获取本机的链路列表. 中继服务器目前充当外网地址探测
    NSDictionary* communicationAddress = [self.engine endPointAddressWithProbeServer:forwardIP port:forwardPort];
    [self.keepSessionAlive invalidate];
    // 获取到外网地址后，开始发送数据包到外网地址探测服务器，直到收到对等方的回复。
#if MANAGER_DEBUG
    NSLog(@"开始进行保持外网session的数据包发送");
#endif
    self.keepSessionAlive = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(keepSession:) userInfo:@{PROBE_PORT_KEY:[NSNumber numberWithInteger:forwardPort],PROBE_SERVER_KEY:forwardIP} repeats:YES];
    //此处我需要做的是字典的数据融合！！！
    NSMutableDictionary* mergeData = [communicationAddress mutableCopy];
    //将信令服务器返回的通话查询请求的响应中的转发地址和目的号码取出来，合并进新的通话请求信令中
    [mergeData addEntriesFromDictionary:@{
                                          DATA_TYPE_KEY:[NSNumber numberWithInteger:SESSION_PERIOD_PROCEED_TYPE],
                                          SESSION_INIT_RES_FIELD_FORWARD_IP_KEY:
                                              [parsedData valueForKey:SESSION_INIT_RES_FIELD_FORWARD_IP_KEY],
                                          SESSION_INIT_RES_FIELD_FORWARD_PORT_KEY:
                                              [parsedData valueForKey:SESSION_INIT_RES_FIELD_FORWARD_PORT_KEY],
                                          SESSION_INIT_REQ_FIELD_DEST_ACCOUNT_KEY: self.selfAccount,
                                          SESSION_SRC_SSID_KEY:[parsedData valueForKey:SESSION_DEST_SSID_KEY], //总是在传递是以接收方的角度去思考
                                          SESSION_DEST_SSID_KEY:[parsedData valueForKey:SESSION_SRC_SSID_KEY],
                                          SESSION_PERIOD_FIELD_PEER_USE_VIDEO:[NSNumber numberWithBool:self.isVideoCall&&self.canVideo]
                                          }];
    //由于信令是发给对方的。所以destAccount和srcaccount应该是从对方的角度去思考。因此destAccount填的是自己的帐号，srcaccount填写的是对方的帐号。这样，在对方看来就是完美的。而且，对等方在构造信令数据时有相同的逻辑
    [mergeData addEntriesFromDictionary:@{SESSION_INIT_REQ_FIELD_SRC_ACCOUNT_KEY:[parsedData valueForKey:SESSION_INIT_REQ_FIELD_DEST_ACCOUNT_KEY]}];
    // 通话请求信令中，需要本机的NAT类型。
    [mergeData addEntriesFromDictionary:@{SESSION_PERIOD_FIELD_PEER_NAT_TYPE_KEY: [NSNumber numberWithInt:natType]}];
    // 构造通话数据请求
    NSDictionary* data = [self.messageBuilder buildWithParams:mergeData];
#if SIGNAL_MESSAGE
    NSLog(@"通话开始阶段的谈判过程，数据往来:%@ mergeData:%@",data,mergeData);
#endif
    [self.TCPcommunicator send:data];
}


- (void) keepSession:(NSTimer*) timer{
#if MANAGER_DEBUG
    NSLog(@"开始发送保持session的数据包");
#endif
    NSDictionary* param = [timer userInfo];
    NSString* probeServerIP = [param valueForKey:PROBE_SERVER_KEY];
    NSInteger port = [[param valueForKey:PROBE_PORT_KEY] integerValue];
    [self.engine keepSessionAlive:probeServerIP port:port];
}
/**
 *  收到终止信令的回复
 *
 *  @param notify 拒绝数据
 */
- (void) sessionHalt:(NSNotification*) notify{
#if MANAGER_DEBUG
    NSLog(@"收到拒绝信令回复");
#endif
    // 关闭可能的保持session的包定时器
    [self.keepSessionAlive invalidate];
    self.keepSessionAlive = nil;
    //收到拒绝也应该终止超时定时器
    [self.monitor invalidate];
    self.monitor = nil;
    NSString* haltType = [notify.userInfo valueForKey:SESSION_HALT_FIELD_TYPE_KEY];
    if ([SESSION_HALT_FILED_ACTION_BUSY isEqualToString:haltType]) {
        [self endSession];
    }else if ([SESSION_HALT_FILED_ACTION_REFUSE isEqualToString:haltType]){
        self.recentLog = @{
                           kStatus:STATUS_REFUSED,
                           kPeerNumber:[notify.userInfo valueForKey:SESSION_INIT_REQ_FIELD_DEST_ACCOUNT_KEY],
                           kCreateDate:[NSDate date]
                           };
        
        [self endSession];
        [self saveCommnicationLog];
    }else if ([SESSION_HALT_FILED_ACTION_END isEqualToString:haltType]){
        [self.engine stopTransport];
        [self endSession];
        [self saveCommnicationLog];
    }else{
        //
    }
    //通知界面，关闭相应的视图
    [[NSNotificationCenter defaultCenter] postNotificationName:END_SESSION_NOTIFICATION object:nil userInfo:nil];
}

/**
 *  通话拒绝
 *  只是做信令数据的构造和发送
 */

-(void) sessionHaltRequest:(NSDictionary*) refuseData{
#if MANAGER_DEBUG
    NSLog(@"发送拒绝信令");
#endif
    //停止可能的保持session的包定时器
    [self.keepSessionAlive invalidate];
    self.keepSessionAlive = nil;
    // 处理参数
    NSDictionary* params = @{
                             DATA_TYPE_KEY:[NSNumber numberWithInteger:SESSION_PERIOD_HALT_TYPE],
                             SESSION_INIT_REQ_FIELD_SRC_ACCOUNT_KEY:[refuseData valueForKey:SESSION_INIT_REQ_FIELD_DEST_ACCOUNT_KEY],
                             SESSION_INIT_REQ_FIELD_DEST_ACCOUNT_KEY:[refuseData valueForKey:SESSION_INIT_REQ_FIELD_SRC_ACCOUNT_KEY],
                             SESSION_HALT_FIELD_TYPE_KEY:[refuseData valueForKey:SESSION_HALT_FIELD_TYPE_KEY]
                             };
#if MANAGER_DEBUG
    NSLog(@"准备发送的终止信令：%@",params);
#endif
    self.messageBuilder = [[IMSessionRefuseMessageBuilder alloc] init];
    NSDictionary* data =  [self.messageBuilder buildWithParams:params];
    [self.TCPcommunicator send:data];
    
    
}

#pragma mark - NOTIFICATION HANDLE

// 信令回复数据的处理 采用通知来完成
- (void) receive:(NSNotification*) notify{
#if MANAGER_DEBUG
    NSLog(@"收到数据，路由给处理逻辑");
#endif
    [self route:notify.userInfo];
}

//收到信令服务器的通话查询响应，进行后续业务
- (void) sessionInited:(NSNotification*) notify{
#if SIGNAL_MESSAGE
    NSLog(@"收到信令服务器的通话查询响应：%@",notify.userInfo);
#endif
    //终止掉超时定时器.这样,后续流程才能进行下去.
    [self.monitor invalidate];
    self.monitor = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SESSION_INITED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:PRESENT_CALLING_VIEW_NOTIFICATION object:nil userInfo:@{
                                                                                                                       SESSION_INIT_REQ_FIELD_DEST_ACCOUNT_KEY:[notify.userInfo valueForKey:SESSION_INIT_REQ_FIELD_DEST_ACCOUNT_KEY],
                                                                                                                       SESSION_INIT_REQ_FIELD_SRC_ACCOUNT_KEY:[self myAccount]
                                                                                                                       }];
    NSMutableDictionary *data = [notify.userInfo mutableCopy];
    //
    [data addEntriesFromDictionary:@{
                                     SESSION_SRC_SSID_KEY:[notify.userInfo valueForKey:SESSION_INIT_RES_FIELD_SSID_KEY],
                                     SESSION_DEST_SSID_KEY:[NSNumber numberWithInteger:[[notify.userInfo valueForKey:SESSION_INIT_RES_FIELD_SSID_KEY] integerValue]+1]}];
    self.messageBuilder = [[IMSessionPeriodRequestMessageBuilder alloc] init];
#if SIGNAL_MESSAGE
    NSLog(@"通话查询请求完成，即将进入通话请求发送阶段");
#endif
    [self sessionPeriodNegotiation:data];
    // 设置10秒超时，如果没有收到接受通话的回复则转到拒绝流程
    [self.monitor invalidate];
    self.monitor = [MSWeakTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(notPickup) userInfo:nil repeats:NO dispatchQueue:dispatch_queue_create("com.itelland.monitor_peer_pickup_queue", DISPATCH_QUEUE_CONCURRENT)];
}
// 没有接听 超时,发sessionend
- (void) notPickup{
    //停止定时器
    [self.monitor invalidate];
    self.monitor = nil;
    //发送终止信令
    [self haltSession:@{
                        SESSION_INIT_REQ_FIELD_SRC_ACCOUNT_KEY:self.state,
                        SESSION_INIT_REQ_FIELD_DEST_ACCOUNT_KEY:[self myAccount],
                        SESSION_HALT_FIELD_TYPE_KEY:SESSION_HALT_FILED_ACTION_END
                        }];
}

- (void) sessionInitFail:(NSNotification*) notify{
    //终止掉超时定时器.这样,后续流程才能进行下去.
    [self.monitor invalidate];
    self.monitor = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SESSION_INITED_NOTIFICATION object:nil];
    self.state = IDLE;
    // TODO: 提示用户 对方不在线
}

- (void) droppedFromSignal:(NSNotification*) notify{
    NSLog(@"我被踢下线了!!!!!!!");
    //当前用户被其他用此账号登陆的客户端踢下线了. 断开连接.提示当前用户,然后登出.
    if (![self.state isEqualToString: IDLE]) {
        if (self.recentLog) {
            [self.engine stopTransport];
        }
        [self endSession];
        [self saveCommnicationLog];
    }
    
    [self tearDown];
    //提示用户
    UIAlertView* multiLoginAlert = [[UIAlertView alloc] initWithTitle:@"被踢下线通知" message:@"您的账号已在别处登陆.如果不是您本人操作,那么账号有可能被盗.请联系客服." delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
    [multiLoginAlert show];

}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //通知系统,登出当前用户
    [[NSNotificationCenter defaultCenter] postNotificationName:@"signOut" object:nil userInfo:nil];
}
- (void)alertViewCancel:(UIAlertView *)alertView{
    alertView.delegate = nil;
}
/**
 *
 *
 *  @param void
 *
 *  @return <#return value description#>
 */
//收到peer端的请求类型，则首先检查自己是否是被占用状态。
//在非占用状态下，10秒内用户主动操作接听，则开始构造响应类型数据，同时本机设置为占用状态，然后开始获取p2p的后续操作
- (void) sessionPeriod:(NSNotification*) notify{
    NSString* currentDest = [notify.userInfo valueForKey:SESSION_INIT_REQ_FIELD_DEST_ACCOUNT_KEY];
    //如果收到的通话信令就是自己正在拨打的。则表明自己是拨打方，可以开始p2p流程了
    if ([self.state isEqualToString:currentDest]) {
#if MANAGER_DEBUG
        NSLog(@"开始通话，停止session保持数据包的发送，开始获取p2p通道");
        NSLog(@"主叫方收到PEER的链路数据：%@",notify.userInfo);
#endif
        //开始获取p2p通道，保持session的数据包可以停止发送了。
        [self.keepSessionAlive invalidate];
        self.keepSessionAlive = nil;
        //停止主叫方的超时定时器
        [self.monitor invalidate];
        self.monitor = nil;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startTransportAndNotify:) name:P2PTUNNEL_SUCCESS object:nil];
        //告诉引擎，目前是否是视频通话
        [self setIsVideoCall: [[notify.userInfo valueForKey:SESSION_PERIOD_FIELD_PEER_USE_VIDEO] boolValue]&&self.canVideo&&self.isVideoCall];
        [notify.userInfo setValue:[NSNumber numberWithBool:self.isVideoCall] forKey:SESSION_PERIOD_FIELD_PEER_USE_VIDEO];
        [self.engine tunnelWith:notify.userInfo];
        
    }
    //如果是idle状态下，接到了通话信令，则是有人拨打
    else if ([self.state isEqualToString:IDLE]){
#if MANAGER_DEBUG
        NSLog(@"被叫方收到通话请求，等待用户操作接听");
#endif
        //根据收到的usevideo和自身是否支持视频 设置自己是否有视频选项
        [self setIsVideoCall: [[notify.userInfo valueForKey:SESSION_PERIOD_FIELD_PEER_USE_VIDEO] boolValue]&&self.canVideo];
        [notify.userInfo setValue:[NSNumber numberWithBool:self.isVideoCall] forKey:SESSION_PERIOD_FIELD_PEER_USE_VIDEO];
        //通知界面，弹出通话接听界面:[self sessionPeriodResponse:notify]
        [[NSNotificationCenter defaultCenter] postNotificationName:SESSION_PERIOD_REQ_NOTIFICATION object:nil userInfo:notify.userInfo];
        //开启被叫方定时器10秒超时则拒绝
        [self.monitor invalidate];
        self.monitor = [MSWeakTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(notPickup) userInfo:nil repeats:NO dispatchQueue:dispatch_queue_create("com.itelland.monitor_not_willing_to_answer_queue", DISPATCH_QUEUE_CONCURRENT)];
    }else{//剩余的情况表明。当前正在通话中，应该拒绝 这里会是自动拒绝
        //构造拒绝信令
#if MANAGER_DUBG
        NSLog(@"当前的对方号码为：%@",currentDest);
#endif
        NSDictionary* busyData = @{
                                   DATA_TYPE_KEY:[NSNumber numberWithInteger:SESSION_PERIOD_HALT_TYPE],
                                   SESSION_INIT_REQ_FIELD_SRC_ACCOUNT_KEY:[self myAccount],
                                   SESSION_INIT_REQ_FIELD_DEST_ACCOUNT_KEY:currentDest,
                                   SESSION_HALT_FIELD_TYPE_KEY:SESSION_HALT_FILED_ACTION_BUSY
                                   };
        [self sessionHaltRequest:busyData];
    }
}
//如果是处理的peer端的响应类型。那么，有可能是接受通话，则接下来开始进行p2p通道获取; 也有可能是拒绝通话，则通话请求终止
- (void) sessionPeriodResponse:(NSNotification*) notify{
    //首先，开启会话，设置处于占线状态
    if (NO == [self startSession:[notify.userInfo valueForKey:SESSION_INIT_REQ_FIELD_DEST_ACCOUNT_KEY]] ) {
        return;
    }
    //既然是接受通话，则信令构造器要换成回复的类型
    self.messageBuilder = [[IMSessionPeriodResponseMessageBuilder alloc] init];
    
    // 把自身的链路信息作为响应发出，表明本机接受通话请求
    [self sessionPeriodNegotiation:notify.userInfo];
    // 开始获取p2p通道
    [self.keepSessionAlive invalidate];
    self.keepSessionAlive = nil;
    NSLog(@"接受通话请求，停止session保持数据包的发送，开始获取p2p通道");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(justStartTransport:) name:P2PTUNNEL_SUCCESS object:nil];
    //告诉引擎，目前是否是视频通话
    [self.engine tunnelWith:notify.userInfo];
    /**
     *  移到 justStartTransport 方法
     *  测试
     */
    //    [self.engine startTransport];
}
//决定最终是是否使用视频 决定因素:对方是否视频,自己是否支持视频
- (void) candidateUseVideoCall:(BOOL) peerUseVideo{
    if (peerUseVideo && [self canVideo]) {
        [self setIsVideoCall:YES];
    }else{
        [self setIsVideoCall:NO];
    }
}
#pragma mark - 1213 test
/**
 *  因为tunnelWith 方法阻塞操作，将其放到线程中去
 *
 *  @param notify 外部传入
 */
//主叫
- (void) justStartTransport:(NSNotification*) notify{
    [self.engine startTransport];
    //开始通话计时
    self.recentLog = @{
                       kStatus:STATUS_ANSWERED,
                       kPeerNumber:[notify.userInfo valueForKey:SESSION_INIT_REQ_FIELD_DEST_ACCOUNT_KEY],
                       kCreateDate:[NSDate date]
                       };
    
#if OTHER_MESSAGE
    NSLog(@"the log to be saved : %@",self.recentLog);
#endif
    [self startCommunicationCounting];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:P2PTUNNEL_SUCCESS object:nil];
}
// 被叫接听回掉
- (void) startTransportAndNotify:(NSNotification*) notify{
    [self.engine startTransport];
    //开始通话计时
    self.recentLog = @{
                       kStatus:STATUS_CALLED,
                       kPeerNumber:[notify.userInfo valueForKey:SESSION_INIT_REQ_FIELD_DEST_ACCOUNT_KEY],
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

- (void) durationTick{
    self.duration++;
#if OTHER_MESSAGE
    NSLog(@"当前通话持续时间:%f",self.duration);
#endif
}
//开始为本次通话计时
- (void) startCommunicationCounting{
    //状态归零
    [self.communicationTimer invalidate];
    self.duration = 0.0;
    self.communicationTimer = [MSWeakTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(durationTick) userInfo:nil repeats:YES dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
}
//结束本次通话计时
- (void) stopCommunicationCounting{
    if (self.communicationTimer) {
        [self.communicationTimer invalidate];
        self.communicationTimer = nil;
    }
    
}
//在通话session结束时,停止通话计时.保存.
- (void) saveCommnicationLog{
    //如果recentLog为空,则不需要记录.因为只有在通信通道(p2p通道/转发通道)建立后才会有recentLog
    if (![self.recentLog valueForKey:kPeerNumber]) {
        return;
    }
    ItelUser* peer =  [[ItelAction action] userInFriendBook:[self.recentLog valueForKey:kPeerNumber]];
    if (!peer) {
        peer = [ItelUser userWithDictionary:@{@"itel":[self.recentLog valueForKey:kPeerNumber]}];
        peer.remarkName = @"陌生人";
        peer.nickName = @"某帅";
        peer.imageurl = @"http://wwc.taobaocdn.com/avatar/getAvatar.do?userId=352958000&width=100&height=100&type=sns";
        peer.isFriend = [NSNumber numberWithBool:NO];
        [[IMCoreDataManager defaulManager] saveContext];
    }
    Recent* aRecent = [Recent recentWithCallInfo:@{
                                                   kPeerNumber:[self.recentLog valueForKey:kPeerNumber],
                                                   kStatus:[self.recentLog valueForKey:kStatus],
                                                   kDuration:@(self.duration),
                                                   kCreateDate:[self.recentLog valueForKey:kCreateDate],
                                                   kPeerRealName:peer.remarkName,
                                                   kPeerNick:peer.nickName,
                                                   kPeerAvatar:peer.imageurl,
                                                   kHostUserNumber:self.myAccount
                                                   }
                                       inContext:[[IMCoreDataManager defaulManager] managedObjectContext]];
#if MANAGER_DEBUG
    NSLog(@"aRecent is :%@",aRecent);
#endif
}
//收到信令服务器的验证响应，
- (void) authHasResult:(NSNotification*) notify{
#if MANAGER_DEBUG
    NSLog(@"收到信令服务器端帐号验证响应~");
#endif
#if SIGNAL_MESSAGE
    NSLog(@"信令服务器的验证响应：%@",notify.userInfo);
#endif
}

#pragma mark - INTERFACE

// IMManager 接口的实现
- (void)setup{
    [self injectDependency];
    //环境初始化
//    [self.engine initNetwork];
    
//    [self.engine initMedia];
    self.state = IDLE;
}

- (void)connectToSignalServer{
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
    [self.UDPcommunicator connect:self.selfAccount];
}

- (void) connectToSignalServer:(NSNotification*) notify{
    //设置长连接地址
    NSDictionary* addressData = notify.userInfo;
    [self.TCPcommunicator setupIP: [[addressData valueForKey:BODY_SECTION_KEY] valueForKey:UDP_INDEX_RES_FIELD_SERVER_IP_KEY]];
    [self.TCPcommunicator setupPort:[[[addressData valueForKey:BODY_SECTION_KEY] valueForKey:UDP_INDEX_RES_FIELD_SERVER_PORT_KEY] intValue]];
    
    
    //连接信令服务器
    [self.TCPcommunicator connect:self.selfAccount];
    [self.TCPcommunicator keepAlive];
#if MANAGER_DEBUG
    NSLog(@"目前的本机帐号：%@",[self myAccount]);
#endif
    [self auth:self.selfAccount cert:@"chengjianjun"];
}
- (void)disconnectToSignalServer{
    [self.TCPcommunicator disconnect];
    [self removeNotifications];
}
// 从信令服务器注销
- (void)logoutFromSignalServer{
    self.messageBuilder = [IMLogoutFromSignalServerMessageBuilder new];
    NSDictionary* data = [self.messageBuilder
                          buildWithParams:@{
                                            CMID_APP_LOGIN_SSS_REQ_FIELD_ACCOUNT_KEY: [self myAccount]
                                            }];
#if SIGNAL_MESSAGE
    NSLog(@"信令服务器的注销请求：%@",data);
#endif
    [self.TCPcommunicator send:data];
}
/**
 *  注销用户时删除保存的本地数据
 */
- (void) clearTable{
    //删除所有表中的数据
    NSError* error;
    NSArray* tableNames = @[
                            @"HostItelUser",
                            @"Message",
                            @"ItelUser",
                            @"Recent"
                            
                            ];
    //从数组中获得表名.依次删除
    for (NSString* tableName in tableNames) {
        NSFetchRequest* clearTableRequest = [NSFetchRequest fetchRequestWithEntityName:tableName];
        NSArray* hostUsers = [[IMCoreDataManager defaulManager].managedObjectContext executeFetchRequest:clearTableRequest error:&error];
        for (NSManagedObject* o in hostUsers) {
            [[IMCoreDataManager defaulManager].managedObjectContext deleteObject:o];
        }
        
    }
    [[IMCoreDataManager defaulManager] saveContext];
}
/**
 *  将Manager管理的对象全部销毁
 */
- (void) tearDown{
#if MANAGER_DEBUG
    NSLog(@"call tearDown");
#endif
    [[IMCoreDataManager defaulManager] saveContext];
    [self disconnectToSignalServer];
//    [self.engine tearDown];
    self.engine=nil;
    self.TCPcommunicator =  nil;
    self.UDPcommunicator = nil;
    self.messageBuilder = nil;
}
- (BOOL)startSession:(NSString*) destAccount{
    if (!destAccount ||
        [destAccount isEqualToString:BLANK_STRING] ||
        [destAccount isEqualToString:self.selfAccount] ||
        [self.state isEqualToString:destAccount]) {
        return NO;
    }
    self.state = destAccount;
    return YES;
}
- (void)endSession{
    self.state = IDLE;
    [self.engine tearDown];
    [self stopCommunicationCounting];
    
}

- (void)dial:(NSString *)account{
    [self testSessionStart:account];
}
// 用户点击时，将通知数据传入
- (void) acceptSession:(NSNotification*) notify{
    //终止超时定时器
    [self.monitor invalidate];
    self.monitor = nil;
    //被叫方发送通话链路
    [self sessionPeriodResponse:notify];
}
// 终止当前的通话
- (void)haltSession:(NSDictionary*) data{
    if ([[data valueForKey:SESSION_HALT_FIELD_TYPE_KEY] isEqualToString:SESSION_HALT_FILED_ACTION_REFUSE]) {
        self.recentLog = @{
                           kStatus:STATUS_REFUSED,
                           kPeerNumber:[data valueForKey:SESSION_INIT_REQ_FIELD_DEST_ACCOUNT_KEY],
                           kCreateDate:[NSDate date]
                           };
    }
    [self.engine stopTransport];
    [self sessionHaltRequest:data];
    [self endSession];
    [self saveCommnicationLog];
    //通知界面，关闭相应的视图
    [[NSNotificationCenter defaultCenter] postNotificationName:END_SESSION_NOTIFICATION object:nil userInfo:nil];
}

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
- (void)setMyAccount:(NSString *)account{
    self.selfAccount = account;
}
- (NSString *)myAccount{
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
@end
