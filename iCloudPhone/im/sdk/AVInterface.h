#pragma once

#include <iostream>

#include "APITypes.h"

struct stVoiceEngineData;
struct stVideoEngineData;

enum MediaType
{
    MTVoe = 0,
    MTVie,
    MTAll
};

enum InitType
{
    InitTypeNone = -1,
    InitTypeVoe = 0,
    InitTypeVoeAndVie = 1
};

class CAVInterfaceAPI
{
public:
    CAVInterfaceAPI();
    ~CAVInterfaceAPI();

private:
    //////////////////////////////////////////////////////////////////////////
    ///@brief 音频引擎初期化
    ///
    ///@param[cusTtansport] 数据传输注册类
    ///@param[cusTraceCallback] 日志打印注册类
    ///
    ///@return true false
    //////////////////////////////////////////////////////////////////////////
    bool VoeInit();
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 音频引擎退出
    ///
    ///@param[]
    ///
    ///@return true false
    //////////////////////////////////////////////////////////////////////////
    bool VoeExit();
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 视频引擎的初期化
    ///
    ///@param[]
    ///
    ///@return true false
    //////////////////////////////////////////////////////////////////////////
    bool VieInit();
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 视频引擎退出
    ///
    ///@param[]
    ///
    ///@return true false
    //////////////////////////////////////////////////////////////////////////
    bool VieExit();
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 设置音视频环境
    ///
    ///@param[type:0(音频) 1（视频）]
    ///
    ///@return true false
    //////////////////////////////////////////////////////////////////////////
    bool setUpAVEnv(int type);
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 创建一个音频channel
    ///
    ///@param[]
    ///
    ///@return 音频channel 小于0:失败
    //////////////////////////////////////////////////////////////////////////
    int CreateVoeChannel();
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 打开音频工作引擎
    ///
    ///@param[]
    ///
    ///@return 0是成功 其他是失败
    //////////////////////////////////////////////////////////////////////////
    int OpenVoeWork();
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 创建视频和摄像头通道
    ///
    ///@param[in] 摄像头采集的视频宽
    ///@param[in] 摄像头采集的视频高
    ///@param[in] 音频通道，主要用于音视频绑定
    ///
    ///@return 视频channel 小于0是失败
    //////////////////////////////////////////////////////////////////////////
    int CreateVieChannel();
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 开启视频引擎
    ///
    ///@param[in] 视频通道
    ///
    ///@return 0是成功 其他是失败
    //////////////////////////////////////////////////////////////////////////
    int OpenVieWork();
    
public:
    //////////////////////////////////////////////////////////////////////////
    ///@brief 退出
    ///
    ///@param[]
    ///
    ///@return true false
    //////////////////////////////////////////////////////////////////////////
    bool Terminate();
    
public:
    /*********************************网络api接口********************************/
    //////////////////////////////////////////////////////////////////////////
    ///@brief 网络初期化
    ///
    ///@param[]
    ///
    ///@return true false
    //////////////////////////////////////////////////////////////////////////
    bool NetWorkInit(int localPort);
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 发送用户数据
    ///
    ///@param[const void *]数据
    ///@param[int]长度
    ///@param[const char*]目标地址ip
    ///@param[uint16_t]目标地址端口
    ///
    ///@return 发送数据长度
    //////////////////////////////////////////////////////////////////////////
    int SendUserData(const void *data, int len, const char* ipaddr, uint16_t port);
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 获取外网地址
    ///
    ///@param[probe_ip]地址探测的服务器IP
    ///@param[probe_port]地址探测的服务器端口
    ///@param[inter_ip]外网IP
    ///@param[inter_port]外网端口
    ///
    ///@return 0:成功 -1：失败
    //////////////////////////////////////////////////////////////////////////
    int GetSelfInterAddr(const char* probe_ip, uint16_t probe_port, char* inter_ip, uint16_t& inter_port);
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 获取P2P通道地址
    ///
    ///@param[argc]P2P用到的参数，以及出来的参数值
    ///
    ///@return 0:成功 -1：失败
    //////////////////////////////////////////////////////////////////////////
    int GetP2PPeer(TP2PPeerArgc& argc);
    
    
    /*********************************媒体api接口********************************/
    //////////////////////////////////////////////////////////////////////////
    ///@brief 媒体引擎初期化
    ///
    ///@param[]
    ///
    ///@return true false
    //////////////////////////////////////////////////////////////////////////
    InitType MediaInit(int width = 0, int height = 0, InitType type = InitTypeNone);
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 开启媒体
    ///
    ///@param[type]媒体类型
    ///@param[dest_address]对端的ip地址
    ///@param[dest_port]对端的端口
    ///
    ///@return true false
    //////////////////////////////////////////////////////////////////////////
    bool StartMedia(InitType type, const char* dest_address, uint16_t dest_port);
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 关闭媒体
    ///
    ///@param[type]媒体类型
    ///
    ///@return true false
    //////////////////////////////////////////////////////////////////////////
    bool StopMedia(InitType type);
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 设置静音模式
    ///
    ///@param[type]媒体类型
    ///@param[enble]true:开启 false:关闭
    ///
    ///@return void
    //////////////////////////////////////////////////////////////////////////
    void SetMuteEnble(MediaType type, bool enble);
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 获取媒体数据统计
    ///
    ///
    ///@return 媒体数据统计
    //////////////////////////////////////////////////////////////////////////
    unsigned int GetTopMediaDataSize();
    
    /*********************************音频api接口********************************/
    //////////////////////////////////////////////////////////////////////////
    ///@brief 音频控制参数接口
    ///
    ///@param[int] 音频channel
    ///
    ///@return 0是成功 其他是失败
    //////////////////////////////////////////////////////////////////////////
    int SetVoEControlParameters(VoEControlParameters& param);
    
    /*********************************视频api接口********************************/
    //////////////////////////////////////////////////////////////////////////
    ///@brief 开启摄像头通道
    ///
    ///@param[in] 摄像头序号 0:前置摄像头 1:后置摄像头
    ///
    ///@return 0:成功 1:失败
    //////////////////////////////////////////////////////////////////////////
    int StartCamera(int cameraNum);
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 改变摄像头
    ///
    ///@param[in] 摄像头序号 0:前置摄像头 1:后置摄像头
    ///
    ///@return 0:成功 1:失败
    //////////////////////////////////////////////////////////////////////////
    int SwitchCamera(int cameraNum);
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 设置远程图像显示窗口
    ///
    ///@param[in] 视频channel
    ///@param[in] 远程图像显示窗口
    ///
    ///@return 0:成功 -1：失败
    //////////////////////////////////////////////////////////////////////////
    int VieAddRemoteRenderer(void* view);
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 设置本地图像显示窗口
    ///
    ///@param[in] 视频channel
    ///@param[in] 本地图像显示窗口
    ///
    ///@return 0:成功 -1：失败
    //////////////////////////////////////////////////////////////////////////
    int VieAddLocalRenderer(void* view);
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 获取摄像头方向（0:前置摄像头 1:后置摄像头）
    ///
    ///@param[in] 摄像头编号
    ///
    ///@return -1：失败 其他值是方向值
    //////////////////////////////////////////////////////////////////////////
    int VieGetCameraOrientation(int cameraNum);
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 设置摄像头方向
    ///
    ///@param[in] 摄像头通道
    ///@param[in] 方向角度
    ///
    ///@return 0:成功 -1：失败
    //////////////////////////////////////////////////////////////////////////
    int VieSetRotation(int degrees);
    
    //////////////////////////////////////////////////////////////////////////
    ///@brief 在外网地址探测和p2p探测的过程中，调用此接口可以终止这些阻塞业务，然函数返回
    ///
    ///@return 0:成功 -1：失败
    //////////////////////////////////////////////////////////////////////////
    int StopDetect();
    
private:
    // 音频引擎参数
    stVoiceEngineData* voeData;
    // 视频引擎参数
    stVideoEngineData* vieData;
    
    int m_voeChannel;// 音频通道
    int m_vieChannel;// 视频通道
    int m_cameraId;// 摄像头ID
    int m_width;// 视频采集的宽
    int m_height;// 视频采集的高
    InitType m_initType;// 初期化类型
    
    volatile bool peer_flg;// 探测标志
};
