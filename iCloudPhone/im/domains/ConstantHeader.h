//
//  ConstantHeader.h
//  im
//
//  Created by Pharaoh on 13-11-20.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#ifndef im_ConstantHeader_h
#define im_ConstantHeader_h
//客户端状态值
enum AccountStatusTypes
{
    AST_INVALID = -1,
    AST_ONLINE,// 在线
    AST_OFFLINE,// 离线
    AST_LOGOUT// 注销
};

//客户端类型值：
enum AccountClientTypes
{
    ACT_INVALID = -1,
    ACT_ANDROID,// android客户端
    ACT_IOS,// IOS客户端
    ACT_WINDOWS,// windows客户端
    ACT_MAC// mac客户端
};
enum emDataType
{
    EDT_INVALID = -1,
    EDT_SIGNEL,// 信令数据
    EDT_MSG// 消息数据
};
// 常量定义
#define PRESENT_CALLING_VIEW_NOTIFICATION @"PRESENT_CALLING_VIEW_NOTIFICATION" // 通知加载"拨号中"界面
#define PRESENT_ANSWERING_VIEW_NOTIFICATION @"PRESENT_ANSWERING_VIEW_NOTIFICATION"// 通知加载“待接听”界面
#define PRESENT_INSESSION_VIEW_NOTIFICATION @"PRESENT_INSESSION_VIEW_NOTIFICATION"// 通知加载“通话中界面”
#define PARSED_DATA_KEY @"PARSED_DATA_KEY" //数据暂存池的key
#define DIALING_SOUND_ID 1152 //拨号的声音



#define PRESENT_DIAL_VIEW_NOTIFICATION @"PRESENT_DIAL_VIEW_NOTIFICATION" //
#define UDP_LOOKUP_COMPLETE_NOTIFICATION @"UDP_LOOKUP_COMPLETE_NOTIFICATION" //udp查询完成,应该能够获得信令服务器地址
#define DATA_RECEIVED_NOTIFICATION @"DATA_RECEIVED_NOTIFICATION" // 收到通知标识
#define SESSION_INITED_NOTIFICATION @"SESSION_INITED_NOTIFICATION" // 收到通话查询响应
#define SESSION_PERIOD_NOTIFICATION @"SESSION_PERIOD_NOTIFICATION" // 收到通话查询响应

#define SESSION_PERIOD_CALLING_COME_NOTIFICATION @"SESSION_PERIOD_CALLING_COME_NOTIFICATION" // 通知被叫接收
#define SESSION_PERIOD_ANSWERING_COME_NOTIFICATION @"SESSION_PERIOD_ANSWERING_NOTIFICATION" // 通知主叫接收
#define SESSION_PERIOD_HALT_NOTIFICATION @"SESSION_PERIOD_HALT_NOTIFICATION"// 收到拒绝通话的响应  
#define SESSION_PERIOD_REQ_NOTIFICATION @"SESSION_PERIOD_REQ_NOTIFICATION" // 收到通话请求
#define SESSION_PERIOD_RES_NOTIFICATION @"SESSION_PERIOD_RES_NOTIFICATION" // 收到通话响应
#define CMID_APP_LOGIN_SSS_NOTIFICATION @"CMID_APP_LOGIN_SSS_NOTIFICATION" // 收到信令服务器验证回复
#define END_SESSION_NOTIFICATION @"END_SESSION_NOTIFICATION" //终止会话
#define SIGNAL_ERROR_NOTIFICATION @"SIGNAL_ERROR_NOTIFICATION" //收到异常信令数据
#define DROPPED_FROM_SIGNAL_NOTIFICATION @"DROPPED_FROM_SIGNAL_NOTIFICATION" //被踢下线通知
#define P2PTUNNEL_SUCCESS @"P2PTUNNEL_SUCCESS"
#define P2PTUNNEL_FAILED @"P2PTUNNEL_FAILED"
#define RECONNECT_TO_SIGNAL_SERVER_NOTIFICATION @"reconnect"
#define OPEN_CAMERA_SUCCESS_NOTIFICATION @"OPEN_CAMERA_SUCCESS_NOTIFICATION"
#define OPEN_CAMERA_FAILED_NOTIFICATION @"OPEN_CAMERA_FAILED_NOTIFICATION"
//manager.state
#define kMyAccount @"myAccount"
#define kPeerAccount @"peerAccount"
#define kPeerSSID @"peerSSID"
#define kMySSID @"mySSID"
#define kForwardIP @"ForwardIP"
#define kForwardPort @"ForwardPort"
// signal keys

#define kHead @"head"
#define kBody @"body"
#define kType @"type"
#define kStatus @"status"
#define kSeq @"seq"
#define kData @"data"
#define kDataType @"datatype"
#define kAccount @"account"
#define kDomain @"domain"
#define kHostItelNumber @"hostItelNumber"
#define kSrvType @"srvtype"
#define kIP @"ip"
#define kPort @"port"

// 信令服务器认证信令字段
#define kClientType @"clienttype"
#define kClientStatus @"clientstatus"
#define kToken @"token"

// 目录服务器请求字段
#define UDP_INDEX_ROUTE_SERVER_TYPE @0
#define UDP_INDEX_GATEWAY_SERVER_TYPE @1


// 通话查询信令字段
#define kDestAccount @"destaccount" // 请求: destAccount
#define kSrcAccount @"srcaccount" // 请求：srcAccount

#define kSessionID @"sessionid" // 回复: ssid
#define kSrcSSID @"srcssid"
#define kDestSSID @"destssid"

#define kRelayIP @"relayip" // 回复： forwardIP
#define kRelayPort @"relayport" // 回复： forwardIP

// 通话信令字段
#define kPeerNATType @"peerNATType" //发送给对方的，本机的NAT类型
#define kPeerInterIP @"peerInterIP"
#define kPeerPort @"peerInterPort"
#define kPeerLocalIP @"peerLocalIP"
#define kPeerLocalPort @"peerLocalPort"
#define kUseVideo @"useVideo"
//通话终止信令字段
#define kHaltType @"halttype"
#define kRefuseSession @"refusesession" //接收方需要终止session
#define kBusy @"busy" //接收方只需要终止session
#define kEndSession @"endsession" //接收方要终止传输

#define SEQ_BASE 0 // 发送包的序列号基底
#define HEART_BEAT_INTERVAL 5 // 心跳间隔15秒
#define HEART_BEAT_REQ_TYPE 0x00000000 //心跳包请求类型

#define ROUTE_SERVER_IP_REQ_TYPE 0x00000001 // 目录服务器地址请求
#define ROUTE_SERVER_IP_RES_TYPE 0x00010001 // 目录服务器地址请求响应

#define SESSION_INIT_REQ_TYPE 0x00000003  // 通话查询请求
#define SESSION_INIT_RES_TYPE 0x00010003  // 通话查询响应

#define CMID_APP_LOGIN_SSS_REQ_TYPE 0x00000002 // app客户端登录业务服务器请求
#define CMID_APP_LOGIN_SSS_RESP_TYPE 0x00010002 // app客户端登录业务服务器应答

#define SESSION_PERIOD_REQ_TYPE 0x00000004 // 通话过程请求
#define SESSION_PERIOD_RES_TYPE 0x00000004 // 通话过程响应

#define CMID_APP_LOGOUT_SSS_REQ_TYPE 0x00000005 // app客户端从业务服务器注销

#define CMID_APP_DROPPED_SSS_REQ_TYPE 0x00000006 // 当客户端被踢下线时,会收到信令服务器的通知.
#define SESSION_PERIOD_PROCEED_TYPE 1024 //表明发送的是通话链接类型 是SESSION_PERIOD的子类型。因为会出现发送通话链接请求，而对方回复通话拒绝的情况
#define SESSION_PERIOD_CALLING_TYPE 1024 //主叫方发出的类型
#define SESSION_PERIOD_ANSWERING_TYPE 4096 //被叫方发出的类型
#define SESSION_PERIOD_HALT_TYPE 0x00000800 //表明发送的是通话终止类型

#define HEAD_REQ 0x01111111  // 是数据长度meta包
#define COMMON_PKG_RES 0x01111110 //这表明数据包是一个业务数据

#define NORMAL_STATUS 0

#define IN_USE @"IN_USE"
#define IDLE @"IDLE"
#define BLANK_STRING @""
#define SCREEN_WIDTH 144
#define SCREEN_HEIGHT 192
#define SCREEN_HEIGHT_FOR_LOW 176
#define SIGNAL_SERVER_PORT 9989
#define ROUTE_SERVER_IP @"192.168.1.110"
#define ROUTE_SERVER_PORT 9000 // 通话模块会先绑定登陆服务器的9000端口,用于请求路由,网关服务器的地址.
#define ROUTE_SRV_TAG 0x000000fd
#define ROUTE_GATEWAY_TAG 0x000000fe
#define ROUTE_UDP_SEQENCE_END_TAG 0x000000ff
#define LOCAL_PORT 11111
#define LOCAL_UDP_PORT 44444
#define PROBE_SERVER_KEY @"PROBE_SERVER"
#define PROBE_PORT_KEY @"PROBE_PORT"
#define DIAL_PAN_VIEW_CONTROLLER_ID @"DialPanView"
#define DIAL_MANAGER_VIEW_CONTROLLER_ID @"Dial Panel ViewController"
#define CALLING_VIEW_CONTROLLER_ID @"CallingView"
#define ANSWERING_VIEW_CONTROLLER_ID @"AnsweringView"
#define INSESSION_VIEW_CONTROLLER_ID @"InSessionWithVoiceView"
#define MAIN_STORY_BOARD @"iCloudPhone"

#define SUGGEST_CELL_VIEW_IDENTIFIER @"SuggestCellView"

#define STATUS_BAR_HEIGHT 30 // 顶部status bar的高度
#define FULL_SCREEN [[UIScreen mainScreen] bounds]
#define APP_SCREEN [[UIScreen mainScreen] applicationFrame]
#define PATH_OF_APP_HOME    NSHomeDirectory()
#define PATH_OF_TEMP        NSTemporaryDirectory()
#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define ONE_DAY_TIME_IN_SECONDS 86400.0


#define TABLE_NAME_RECENT @"Recent"
#define kPeerAvatar  @"peerAvatar"
#define kPeerRealName @"peerRealName"
#define kPeerNumber @"peerNumber"
#define kPeerNick @"peerNick"
#define kCreateDate @"createDate"
#define kDuration @"duration"
#define kHostUserNumber @"hostUserNumber"

#define STATUS_CALLED @"called"
#define STATUS_ANSWERED @"answered"
#define STATUS_MISSED @"missed"
#define STATUS_REFUSED @"refused"


#endif
