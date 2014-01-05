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
// 常量定义
#define PRESENT_CALLING_VIEW_NOTIFICATION @"PRESENT_CALLING_VIEW_NOTIFICATION" // 通知加载"拨号中"界面
#define PRESENT_ANSWERING_VIEW_NOTIFICATION @"PRESENT_ANSWERING_VIEW_NOTIFICATION"// 通知加载“待接听”界面
#define PRESENT_INSESSION_VIEW_NOTIFICATION @"PRESENT_INSESSION_VIEW_NOTIFICATION"// 通知加载“通话中界面”
#define PARSED_DATA_KEY @"PARSED_DATA_KEY" //数据暂存池的key
#define DIALING_SOUND_ID 1151 //拨号的声音

#define PRESENT_DIAL_VIEW_NOTIFICATION @"PRESENT_DIAL_VIEW_NOTIFICATION" //
#define UDP_LOOKUP_COMPLETE_NOTIFICATION @"UDP_LOOKUP_COMPLETE_NOTIFICATION" //udp查询完成,应该能够获得信令服务器地址
#define DATA_RECEIVED_NOTIFICATION @"DATA_RECEIVED_NOTIFICATION" // 收到通知标识
#define SESSION_INITED_NOTIFICATION @"SESSION_INITED_NOTIFICATION" // 收到通话查询响应
#define SESSION_PERIOD_NOTIFICATION @"SESSION_PERIOD_NOTIFICATION" // 收到通话查询响应
#define SESSION_PERIOD_HALT_NOTIFICATION @"SESSION_PERIOD_HALT_NOTIFICATION"// 收到拒绝通话的响应  
#define SESSION_PERIOD_REQ_NOTIFICATION @"SESSION_PERIOD_REQ_NOTIFICATION" // 收到通话请求
#define SESSION_PERIOD_RES_NOTIFICATION @"SESSION_PERIOD_RES_NOTIFICATION" // 收到通话响应
#define CMID_APP_LOGIN_SSS_NOTIFICATION @"CMID_APP_LOGIN_SSS_NOTIFICATION" // 收到信令服务器验证回复
#define END_SESSION_NOTIFICATION @"END_SESSION_NOTIFICATION" //终止会话


#define P2PTUNNEL_SUCCESS @"P2PTUNNEL_SUCCESS"

#define HEAD_SECTION_KEY @"head"
#define BODY_SECTION_KEY @"body"
#define DATA_TYPE_KEY @"type"
#define DATA_STATUS_KEY @"status"
#define DATA_SEQ_KEY @"seq"
#define DATA_CONTENT_KEY @"data"
#define ROUTE_SERVER_IP_KEY @"domain"
#define ROUTE_SERVER_PORT_KEY @"port"
// 目录服务器请求字段
#define UDP_INDEX_REQ_FIELD_ACCOUNT_KEY @"account"
#define UDP_INDEX_REQ_FIELD_SRVTYPE_KEY @"srvtype"
#define UDP_INDEX_RES_FIELD_SERVER_IP_KEY @"ip"
#define UDP_INDEX_RES_FIELD_SERVER_PORT_KEY @"port"
#define UDP_INDEX_ROUTE_SERVER_TYPE @0
#define UDP_INDEX_GATEWAY_SERVER_TYPE @1


// 信令服务器认证信令字段
#define CMID_APP_LOGIN_SSS_REQ_FIELD_ACCOUNT_KEY @"account"
//#define CMID_APP_LOGIN_SSS_REQ_FIELD_CERT_KEY @"keys"
#define CMID_APP_LOGIN_SSS_REQ_FIELD_CLIENT_TYPE_KEY @"clienttype"
#define CMID_APP_LOGIN_SSS_REQ_FIELD_CLIENT_STATUS_KEY @"clientstatus"
#define CMID_APP_LOGIN_SSS_REQ_FIELD_TOKEN_KEY @"token"
// 通话查询信令字段
#define SESSION_INIT_REQ_FIELD_DEST_ACCOUNT_KEY @"destaccount" // 请求: destAccount
#define SESSION_INIT_REQ_FIELD_SRC_ACCOUNT_KEY @"srcaccount" // 请求：srcAccount

#define SESSION_INIT_RES_FIELD_SSID_KEY @"sessionid" // 回复: ssid

#define SESSION_SRC_SSID_KEY @"srcssid"
#define SESSION_DEST_SSID_KEY @"destssid"

#define SESSION_INIT_RES_FIELD_FORWARD_IP_KEY @"relayip" // 回复： forwardIP
#define SESSION_INIT_RES_FIELD_FORWARD_PORT_KEY @"relayport" // 回复： forwardIP

// 通话信令字段
#define SESSION_PERIOD_FIELD_PEER_NAT_TYPE_KEY @"peerNATType" //发送给对方的，本机的NAT类型
#define SESSION_PERIOD_FIELD_PEER_INTER_IP_KEY @"peerInterIP"
#define SESSION_PERIOD_FIELD_PEER_INTER_PORT_KEY @"peerInterPort"
#define SESSION_PERIOD_FIELD_PEER_LOCAL_IP_KEY @"peerLocalIP"
#define SESSION_PERIOD_FIELD_PEER_LOCAL_PORT_KEY @"peerLocalPort"
#define SESSION_PERIOD_FIELD_PEER_USE_VIDEO @"useVideo"
//通话终止信令字段
#define SESSION_HALT_FIELD_TYPE_KEY @"halttype"
#define SESSION_HALT_FILED_ACTION_REFUSE @"refusesession" //接收方需要终止session
#define SESSION_HALT_FILED_ACTION_BUSY @"busy" //接收方只需要终止session
#define SESSION_HALT_FILED_ACTION_END @"endsession" //接收方要终止传输

#define SEQ_BASE 0 // 发送包的序列号基底
#define HEART_BEAT_INTERVAL 15 // 心跳间隔15秒
#define HEART_BEAT_REQ_TYPE 0x00000000 //心跳包请求类型

#define ROUTE_SERVER_IP_REQ_TYPE 0x00000001 // 目录服务器地址请求
#define ROUTE_SERVER_IP_RES_TYPE 0x00010001 // 目录服务器地址请求响应

#define SESSION_INIT_REQ_TYPE 0x00000003  // 通话查询请求
#define SESSION_INIT_RES_TYPE 0x00010003  // 通话查询响应

#define CMID_APP_LOGIN_SSS_REQ_TYPE 0x00000002 // app客户端登录业务服务器请求
#define CMID_APP_LOGIN_SSS_RESP_TYPE 0x00010002 // app客户端登录业务服务器应答

#define SESSION_PERIOD_REQ_TYPE 0x00000004 // 通话过程请求
#define SESSION_PERIOD_RES_TYPE 0x00000004 // 通话过程响应

#define SESSION_PERIOD_PROCEED_TYPE 0x00000400 //表明发送的是通话链接类型 是SESSION_PERIOD的子类型。因为会出现发送通话链接请求，而对方回复通话拒绝的情况
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
#define SIGNAL_SERVER_IP @"211.149.147.73"
//#define SIGNAL_SERVER_IP @"211.149.144.15"
#define SIGNAL_SERVER_PORT 9989
#define ROUTE_SERVER_IP @"192.168.1.110"
#define ROUTE_SERVER_PORT 9000 // 通话模块会先绑定登陆服务器的9000端口,用于请求路由,网关服务器的地址.
#define ROUTE_SRV_TAG 0x000000fd
#define ROUTE_GATEWAY_TAG 0x000000fe
#define ROUTE_UDP_SEQENCE_END_TAG 0x000000ff
#define LOCAL_PORT 11111
//#define PROBE_SERVER "118.123.7.92"
//#define PROBE_PORT 11111
#define PROBE_SERVER_KEY @"PROBE_SERVER"
#define PROBE_PORT_KEY @"PROBE_PORT"
#define DIAL_PAN_VIEW_CONTROLLER_ID @"DialPanView"
#define CALLING_VIEW_CONTROLLER_ID @"CallingView"
#define ANSWERING_VIEW_CONTROLLER_ID @"AnsweringView"
#define INSESSION_VIEW_CONTROLLER_ID @"InSessionWithVoiceView"
#define MAIN_STORY_BOARD @"iCloudPhone"

#define SUGGEST_CELL_VIEW_IDENTIFIER @"SuggestCellView"

#define STATUS_BAR_HEIGHT 30 // 顶部status bar的高度
#define FULL_SCREEN [[UIScreen mainScreen] bounds]
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
#define kStatus @"status"
#endif
