//
//  NXInputChecker.h
//  social
//
//  Created by nsc on 13-11-5.
//  Copyright (c) 2013年 itelland. All rights reserved.
//  专门提供各种输入检测

#import <Foundation/Foundation.h>

@interface NXInputChecker : NSObject
+(BOOL)checkCloudNumber:(NSString*)cloudNumber;
+(BOOL)checkPassword:(NSString*)password;
+(BOOL)checkEmpty:(NSString *)string;
+(NSString *)filterStringWithString:(NSString*)string targetString:(NSString*)targetString replaceWithString:(NSString*)newString;

#pragma mark - 检查电话号码
//检查是否为手机号码
+(BOOL)checkPhoneNumberIsMobile:(NSString*)phoneNumber;
//把手机号码设置为标准11位
+(NSString*)resetPhoneNumber11:(NSString*)phoneNumber;
//数组转化为字符串
+(NSString*)changeArrayToString:(NSArray*)array;
//加密显示手机号码
+(NSString*)encodeTelNumber:(NSString*)telNum;
//检查云电话号码

//检查邮箱格式
+(BOOL)checkEmail:(NSString *)email;
+(NSDictionary*)parmetersInUrl:(NSURL*)url;

+(NSData*)dataForByteString:(NSString*)byteString;
//密码加密
+(NSString*)encodePassWord:(NSString*)password;
@end
