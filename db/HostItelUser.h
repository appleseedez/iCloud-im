//
//  HostItelUser.h
//  iCloudPhone
//
//  Created by nsc on 14-1-5.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HostItelUser : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * birthday;
@property (nonatomic, retain) NSNumber * countType;
@property (nonatomic, retain) NSString * domain;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * itelNum;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * personalitySignature;
@property (nonatomic, retain) NSString * port;
@property (nonatomic, retain) NSString * qq;
@property (nonatomic, retain) NSString * sessionId;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSString * spring_security_remember_me_cookie;
@property (nonatomic, retain) NSString * stunServer;
@property (nonatomic, retain) NSString * telNum;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * userId;

@end
