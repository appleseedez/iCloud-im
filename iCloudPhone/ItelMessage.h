//
//  ItelMessage.h
//  iCloudPhone
//
//  Created by nsc on 13-12-26.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ItelUser;

typedef NS_ENUM(NSInteger, itelMessageType){
    itelMessageTypeInviteFriend=1,
}itelMessageType;

@interface ItelMessage : NSObject <NSCoding>
+(ItelMessage*)messageWithDic:(NSDictionary*)data;
@property (nonatomic,strong) NSDictionary *user;
@property (nonatomic)   enum itelMessageType mesType;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *body;
@property (nonatomic,strong) NSString *date;
@property (nonatomic)        BOOL isRead;
@end
