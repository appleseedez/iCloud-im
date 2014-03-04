//
//  ItelNetInterface.h
//  iCloudPhone
//
//  Created by Pharaoh on 1/7/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ItelNetInterface <NSObject>
//匹配通讯录中联系人
-(void)checkAddressBookForItelUser:(NSArray*)phones;
//查找陌生人
-(void)searchUser:(NSString*)search isNewSearch:(BOOL)isNewSearch;
//添加联系人
-(void)addUser:(NSDictionary*)parameters;
//删除联系人
-(void)delUser:(NSDictionary*)parameters;

//添加联系人到黑名单
-(void)addToBlackList:(NSDictionary*)parameters;
//从黑名单中移除
-(void)removeFromBlackList:(NSDictionary*)parameters;
//编辑用户备注
-(void)editUserRemark:(NSString*)newRemark user:(NSDictionary*)parameters;
//刷新好友列表
-(void)refreshUserList:(NSDictionary*)parameters;
//刷新黑名单列表
-(void)refreshBlackList:(NSDictionary*)parameters;
//上传图片
-(void)uploadImage:(NSData*)imageData parameters:(NSDictionary*)parameters;
//修改个人资料
-(void) modifyPersonal:(NSDictionary*)parameters;
//修改手机-验证新号码
-(void) checkNewTelNum:(NSDictionary*)parameters;
//修改手机-发送短信验证码
-(void) modifyPhoneNumCheckCode:(NSDictionary*)parameters;
//修改手机-重新发送短信
-(void) resendPhoneMessage:(NSDictionary*)parameters;
//修改用户密码
-(void)changePassword:(NSDictionary*)parameters;
//修改密保-验证密保
-(void)getPasswordProtection:(NSDictionary*)parameters;
//修改密保-回答问题
-(void)securetyAnsewerQuestion:(NSDictionary*)parameters;
//修改密保-提交修改
-(void)sendSecuretyProduction:(NSDictionary*)parameters;
//查询新消息
-(void)searchNewMessage:(NSDictionary*)parameters;
//刷新消息列表
-(void)refreshForNewMessage:(NSDictionary*)parameters;
//确认好友
-(void)acceptIvitation:(NSDictionary*)parameters;
//退出登录
-(void)logout:(NSDictionary*)parameters;
//启动快鱼
-(void)startOtherApp:(NSDictionary*)parameters;
//检查更新
-(void)checkForNewVersion:(NSDictionary*)parameters;
//远程精确查找
-(void)searchMatchingUserWithItel:(NSDictionary*)parameters;
#pragma mark - 115接口
-(void)search115:(NSDictionary *)parameters;
@end
