//
//  NSCAppDelegate.h
//  iCloudPhone
//
//  Created by nsc on 13-11-14.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMManager.h"
#import "AddressBook.h"
@class NXLoginViewController;
@class RootViewController;
@class ItelPhoneModule;
typedef NS_ENUM(NSInteger,
                setRootViewController) { RootViewControllerLogin = 1,
                                         RootViewControllerMain = 1 << 1, };
typedef NS_ENUM(NSInteger, ConnectionFlag) { ConnectionFlagNoConnection = 0,
                                             ConnectionFlagPending,
                                             ConnectionFlagConnected };
@interface NSCAppDelegate : UIResponder <UIApplicationDelegate>

- (void)changeRootViewController:(setRootViewController)Type
                        userInfo:(NSDictionary *)info;
@property(nonatomic, strong) NSString *UUID;
@property(strong, nonatomic) UIWindow *window;
@property(strong, nonatomic)
    UIWindow *dialPanelWindow; //将拨号盘做成独立的window
@property(nonatomic) BOOL autoLogin;
@property(strong, nonatomic) NXLoginViewController *loginVC;
@property(nonatomic, strong) RootViewController *RootVC;
@property(nonatomic, strong) id<IMManager> manager;
@property(nonatomic) AddressBook *phoneBook; //电话联系人列表
@property(nonatomic) NSDictionary *startExtra;
@property(nonatomic) BOOL ignoreOnce; // 当前是否是后台状态
@property (nonatomic) ItelPhoneModule *phoneModule;
@property(nonatomic) NSNumber *connectionFlag; //标识当前网络状况
@property(nonatomic)
    NSNumber *connetionToSignalServer; // 标记当前是否和信令服务器有连接.
@end
