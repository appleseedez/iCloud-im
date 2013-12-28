//
//  PassManager.h
//  iCloudPhone
//
//  Created by nsc on 13-12-27.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PassManager : NSObject
@property (nonatomic,strong) NSDictionary *questions;
@property (nonatomic,strong) NSString *telephone;
@property (nonatomic,strong) NSString *itel;
@property (nonatomic,strong) NSString *userId;
@property (nonatomic,strong) NSString *securetyID;  //密保是否可用
+(PassManager*)defaultManager;
-(void) checkMessageCode:(NSString*)code;
-(void) sendMessage;
-(void) answerQuestion:(NSString*)question answer:(NSString*)answer;
-(void) modifyPassword:(NSString*)password;

@end
